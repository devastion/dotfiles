local M = {}

---Returns current working directory of buffer
---@return string
function M.get_bufname()
  return vim.api.nvim_buf_get_name(0)
end

---Returns current working directory of buffer
---@return string
function M.get_cwd()
  return vim.fs.dirname(M.get_bufname())
end

---Check if current directory is a git repo
---@return boolean
function M.is_git_repo()
  vim.fn.system("git rev-parse --is-inside-work-tree")
  return vim.v.shell_error == 0
end

---Get root directory of git project
---@return string|nil
function M.get_git_root()
  return vim.fn.systemlist("git rev-parse --show-toplevel")[1]
end

---Get root directory of git project or fallback to current directory
---@return string|nil
function M.get_root_directory()
  if M.is_git_repo() then
    return M.get_git_root()
  end

  return vim.fn.getcwd()
end

return M
