local M = {}

--- Check if current directory is a git repo
---@return boolean
function M.is_git_repo()
  vim.fn.system("git rev-parse --is-inside-work-tree")
  return vim.v.shell_error == 0
end

--- Get root directory of git project
---@return string|nil
function M.get_git_root() return vim.fn.systemlist("git rev-parse --show-toplevel")[1] end

--- Get root directory of git project or fallback to current directory
---@return string|nil
function M.get_root_directory()
  if M.is_git_repo() then
    return M.get_git_root()
  end

  return vim.fn.getcwd()
end

--- Get current buffer directory
---@return string
function M.buffer_dir() return vim.fn.expand("%:p:h") end

--- Get template path for current filetype
---@return string
function M.get_template_path()
  local config_dir = vim.fn.stdpath("config")
  local template_path = config_dir .. "/lua/devastion/templates/template." .. vim.bo.filetype

  return template_path
end

return M
