local usercmd = require("devastion.utils").usercmd
local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup
local file_exists = require("devastion.utils.fs").file_exists
local docker = require("devastion.utils.docker")

local function artisan_select()
  if not file_exists("artisan") then
    vim.notify("No artisan file found", vim.log.levels.ERROR)
    return
  end

  -- Silence PHP warnings + disable telescope
  local cmd = {
    "php",
    "-d",
    "error_reporting=E_ALL&~E_DEPRECATED&~E_WARNING",
    "-d",
    "display_errors=0",
    "artisan",
    "list",
    "--raw",
    "--no-ansi",
  }

  local result = vim
    .system(cmd, {
      text = true,
      env = {
        APP_ENV = "local",
        TELESCOPE_ENABLED = "false",
      },
    })
    :wait()

  if result.code ~= 0 then
    vim.notify("Failed to fetch artisan commands", vim.log.levels.ERROR)
    return
  end

  local commands = {}

  for line in result.stdout:gmatch("[^\r\n]+") do
    -- Only match valid artisan command lines
    local name, desc = line:match("^([%w%-%:]+)%s+(.+)$")

    if name and desc then
      table.insert(commands, {
        label = name .. "  —  " .. desc,
        command = name,
      })
    end
  end

  if #commands == 0 then
    vim.notify("No artisan commands found", vim.log.levels.WARN)
    return
  end

  vim.ui.select(commands, {
    prompt = "Artisan Command",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end

    docker.is_daemon_running(function(is_daemon_running)
      if not is_daemon_running then
        return
      end

      docker.get_container_id("publish", "9000", function(container_id)
        if container_id == "" then
          return
        end

        local workdir = docker.get_container_workdir(container_id)
        local shell = docker.get_container_shell(container_id)
        local docker_cmd = {
          docker.cmd,
          "exec",
          "-i",
          "-w",
          workdir,
          container_id,
          shell,
          "-c",
          'php -d error_reporting="E_ALL&~E_DEPRECATED&~E_WARNING" -d display_errors="0" artisan ' .. choice.command,
        }

        vim.system(docker_cmd, {
          env = {
            APP_ENV = "local",
            TELESCOPE_ENABLED = "false",
          },
        }, function(obj)
          vim.notify(vim.inspect(obj.code))
        end)
      end)
    end)
  end)
end

autocmd({ "VimEnter", "DirChanged" }, {
  desc = "Laravel Extra Commands",
  group = augroup("laravel_extra"),
  callback = function()
    local artisan_exists = file_exists("artisan")
    local artisan_usercmd_exists = vim.fn.exists(":Artisan") == 2

    if artisan_exists and not artisan_usercmd_exists then
      usercmd("Artisan", artisan_select, {})
      vim.notify("Added Artisan user command", vim.log.levels.INFO)
    elseif not artisan_exists and artisan_usercmd_exists then
      vim.api.nvim_del_user_command("Artisan")
      vim.notify("Deleted Artisan user command", vim.log.levels.INFO)
    end
  end,
})
