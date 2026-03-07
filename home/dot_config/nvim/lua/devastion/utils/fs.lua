local M = {}

---Check if file exists
---@return boolean
function M.file_exists(filename)
  return vim.fn.filereadable(filename) == 1
end

return M
