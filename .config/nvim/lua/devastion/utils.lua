local M = {}

---Remap keymap
---@param lhs string
---@param rhs string|function
---@param desc string?
---@param mode string|string[]?
---@param opts vim.keymap.set.Opts?
function M.remap(lhs, rhs, desc, mode, opts)
  opts = opts or {}
  opts.desc = desc
  mode = mode or "n"
  vim.keymap.set(mode, lhs, rhs, opts)
end

---Remove duplicates
---@param list table
---@return table
function M.dedup(list)
  local ret = {}
  local seen = {}
  for _, v in ipairs(list) do
    if not seen[v] then
      table.insert(ret, v)
      seen[v] = true
    end
  end
  return ret
end

---Check if table contains value
---@param table table
---@param value string|number
---@return boolean
function M.table_contains(table, value)
  for i = 1, #table do
    if table[i] == value then
      return true
    end
  end

  return false
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

---Install packages with Mason
---@param packages string[]
function M.mason_install(packages)
  local mr = require("mason-registry")

  mr.refresh(function()
    for _, tool in ipairs(packages) do
      local p = mr.get_package(tool)
      if not p:is_installed() then
        p:install()
      end
    end
  end)
end

---Install treesitter parsers
---@param parsers string[]
function M.ts_install(parsers)
  require("nvim-treesitter").install(parsers)
end

---Check if file is readable
---@param filename string
---@param cwd boolean?
---@return boolean
function M.is_file_readable(filename, cwd)
  local root = cwd and vim.fn.getcwd() or M.get_root_directory()
  local file_path = root .. "/" .. filename

  return vim.fn.filereadable(file_path) == 1
end

---Check if package exists in json or yaml file
---@param filename string
---@param query string|string[]
---@return boolean
function M.package_exists(filename, query)
  local absolute_path = M.get_root_directory() .. "/" .. filename

  if not M.is_file_readable(filename) then
    return false
  end

  local search_for_package = function(q, f)
    if not vim.system({ "yq", q, f }, {}):wait().stdout then
      return false
    end

    vim.schedule(function()
      vim.notify(q .. " matched on " .. filename, vim.log.levels.INFO)
    end)

    return true
  end

  return search_for_package(query, absolute_path)
end

---Safe require a module
---@param module string Module name
---@return any: Module if successful, nil otherwise
function M.safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("Could not require module '" .. module .. "'", vim.log.levels.ERROR)
    return nil
  end
  return result
end

---Check if a command-line tool exists
---@param cmd string The command to check
---@return boolean: True if the command exists, false otherwise
function M.check_cmd_exists(cmd)
  if not cmd or cmd == "" then
    return false
  end

  return vim.fn.executable(cmd) == 1
end

return M
