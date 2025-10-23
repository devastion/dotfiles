local M = {}

local utils = require("devastion.utils")

---Folder grep function
---Allows selecting a folder and running grep in it
---@return nil
function M.folder_grep()
  local fzf_lua = utils.safe_require("fzf-lua")
  if not fzf_lua then
    return
  end

  local fd_command = "fd --type d"

  fzf_lua.fzf_exec(fd_command, {
    prompt = "Select folder > ",
    actions = {
      ["default"] = function(selected)
        if selected and #selected > 0 then
          fzf_lua.live_grep({ cwd = selected[1] })
        end
      end,
    },
  })
end

function M.git_conflicts()
  local fzf_lua = utils.safe_require("fzf-lua")
  if not fzf_lua then
    return
  end

  local cmd = "git diff --name-only --diff-filter=U | xargs -r grep -nH '<<<<<<<' 2>/dev/null"

  fzf_lua.fzf_exec(cmd, {
    prompt = "Git Conflict Markers> ",
    actions = {
      ["default"] = function(selected)
        if selected and #selected > 0 then
          local full_path = selected[1]

          local file, line

          local first_colon = full_path:find(":", 1, true)
          local second_colon = full_path:find(":", first_colon + 1, true)

          if first_colon and second_colon then
            file = full_path:sub(1, first_colon - 1)
            line = full_path:sub(first_colon + 1, second_colon - 1)

            local open_cmd = "e +" .. line .. " " .. vim.fn.fnameescape(file)
            vim.cmd(open_cmd)
          else
            vim.notify("Could not parse conflict line: " .. full_path, vim.log.levels.WARN)
          end
        end
      end,
      ["ctrl-v"] = fzf_lua.actions.vsplit, -- Open in vertical split
      ["ctrl-x"] = fzf_lua.actions.split, -- Open in horizontal split
    },
  })
end

return M
