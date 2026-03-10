local utils = require("devastion.utils")

local M = {}

---Install packages with Mason
---@param packages string[]
function M.mason_install(packages)
  local mr = require("mason-registry")
  local pkgs = type(packages) == "table" and vim.iter(packages):flatten():totable() or { packages }

  vim.schedule(function()
    mr.refresh(function()
      for _, tool in ipairs(utils.dedup(pkgs)) do
        local name, version

        if type(tool) == "table" then
          name = tool[1]
          version = tool.version
        else
          name = tool
        end

        if mr.has_package(name) then
          local p = mr.get_package(name)
          if not p:is_installed() then
            p:install({ version = version })
          end
        end
      end
    end)
  end)
end

---Convert plugin name to full URL
---@param name string
---@return string
local function convert_to_url(name)
  if vim.startswith(name, "http") then
    return name
  end

  if vim.startswith(name, "~/") then
    return vim.fs.normalize(name)
  end

  return "https://github.com/" .. name
end

---@class pkg.add.data
---@field event? vim.api.keyset.events|vim.api.keyset.events[]
---@field cmd? string
---@field pattern? string|string[]
---@field disabled? boolean
---@field config? function
---@field init? function
---@field task? function

---@class pkg.add
---@field src string
---@field name? string
---@field version? string|vim.VersionRange
---@field data? pkg.add.data

---Install plugins via vim.pack.add
---@param packages (string|pkg.add)[]
function M.add(packages)
  local specs = vim
    .iter(packages)
    :map(function(p)
      if type(p) == "table" then
        return vim.tbl_extend("force", p, { src = convert_to_url(p.src) })
      end

      return convert_to_url(p)
    end)
    :totable()

  vim.pack.add(specs, {
    load = function(package)
      local data = package.spec.data or {}

      if data.disabled then
        return
      end

      local function init_vim_package()
        vim.cmd.packadd(package.spec.name)
        if data.init then
          data.init(package)
        end
        if data.config then
          data.config(package)
        end
      end

      if not data.event and not data.cmd then
        init_vim_package()
      end

      if data.event then
        utils.autocmd(data.event, {
          group = utils.augroup("lazy_load_" .. package.spec.name),
          once = true,
          pattern = data.pattern or { "*" },
          callback = init_vim_package,
        })
      end

      if data.cmd then
        utils.usercmd(data.cmd, function(cmd_args)
          pcall(vim.api.nvim_del_user_command, data.cmd)
          init_vim_package()
          vim.api.nvim_cmd({
            cmd = data.cmd,
            args = cmd_args.fargs,
            bang = cmd_args.bang,
            nargs = cmd_args.nargs,
            range = cmd_args.range ~= 0 and { cmd_args.line1, cmd_args.line2 } or nil,
            count = cmd_args.count ~= -1 and cmd_args.count or nil,
          }, {})
        end, {
          nargs = data.nargs,
          range = data.range,
          bang = data.bang,
          complete = data.complete,
          count = data.count,
        })
      end
    end,
    confirm = false,
  })
end

function M.uninstall()
  local packages = vim
    .iter(vim.pack.get())
    :map(function(x)
      return x.spec.name
    end)
    :totable()

  vim.ui.select(packages, {
    prompt = "Uninstall package:",
  }, function(p)
    if p then
      vim.pack.del({ p }, { force = true })
    end
  end)
end

function M.update(package)
  local packages = vim
    .iter(vim.pack.get())
    :map(function(x)
      return x.spec.name
    end)
    :totable()

  vim.ui.select(packages, {
    prompt = "Update package:",
  }, function(p)
    if p then
      vim.pack.update({ p }, { force = true })
    end
  end)
end

function M.updateAll()
  vim.pack.update()
end

function M.prune()
  local inactive_packages = vim
    .iter(vim.pack.get())
    :filter(function(x)
      return not x.active
    end)
    :map(function(x)
      return x.spec.name
    end)
    :totable()

  vim.pack.del(inactive_packages)
end

return M
