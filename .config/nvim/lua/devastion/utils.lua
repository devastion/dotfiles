local M = {}

---Remap keymap
---@param lhs string
---@param rhs string|function
---@param desc string?
---@param mode string|table?
---@param opts table?
function M.remap(lhs, rhs, desc, mode, opts)
  opts = opts or {}
  opts.desc = desc
  mode = mode or "n"
  vim.keymap.set(mode, lhs, rhs, opts)
end

---Create keymap
---@param prefix string
---@return fun(lhs: string, rhs: string|function, desc: string?, mode: string|table?, opts: table?)
function M.map(prefix)
  return function(lhs, rhs, desc, mode, opts)
    opts = opts or {}
    opts.desc = desc
    mode = mode or "n"
    vim.keymap.set(mode, prefix .. lhs, rhs, opts)
  end
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

---Get repository out of url
---@param url string
---@return string url Repository owner/repo
function M.url_to_repository(url)
  -- trim
  url = url:match("^%s*(.-)%s*$")

  -- remove common prefixes
  url = url:gsub("^git@", "") -- git@github.com:owner/repo.git
  url = url:gsub("^https?://", "") -- http(s)://github.com/owner/repo
  url = url:gsub("^ssh://", "") -- ssh://git@github.com/owner/repo

  -- drop hostname and any separators up to the path
  url = url:gsub("^[^/:]+[:/]+", "")

  -- strip trailing .git and any trailing slashes
  url = url:gsub("%.git$", ""):gsub("/+$", "")

  -- capture the final two path segments (owner/repo)
  local owner, repo = url:match("([^/]+)/([^/]+)$")
  if owner and repo then
    return owner .. "/" .. repo
  end

  -- fallback: return input if nothing matched
  return url
end

---Check if current directory is a git repo
---@return boolean
function M.is_git_repo()
  vim.fn.system("git rev-parse --is-inside-work-tree")
  return vim.v.shell_error == 0
end

---Get root directory of git project
---@return string|nil
function M.get_git_root() return vim.fn.systemlist("git rev-parse --show-toplevel")[1] end

---Get root directory of git project or fallback to current directory
---@return string|nil
function M.get_root_directory()
  if M.is_git_repo() then
    return M.get_git_root()
  end

  return vim.fn.getcwd()
end

---Get all configurations in after/lsp/*
---@return table<string>
function M.get_lsp_configs()
  local lsp_configs = {}

  for _, v in ipairs(vim.api.nvim_get_runtime_file("after/lsp/*", true)) do
    local name = vim.fn.fnamemodify(v, ":t:r")
    table.insert(lsp_configs, name)
  end

  return lsp_configs
end

---Better foldtext
---@return table
function M.custom_foldtext()
  local function fold_virt_text(result, s, lnum, coloff)
    if not coloff then
      coloff = 0
    end

    local text = ""
    local hl
    for i = 1, #s do
      local char = s:sub(i, i)
      local hls = vim.treesitter.get_captures_at_pos(0, lnum, coloff + i - 1)
      local _hl = hls[#hls]
      if _hl then
        local new_hl = "@" .. _hl.capture
        if new_hl ~= hl then
          table.insert(result, { text, hl })
          text = ""
          hl = nil
        end
        text = text .. char
        hl = new_hl
      else
        text = text .. char
      end
    end
    table.insert(result, { text, hl })
  end

  local start = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
  local end_str = vim.fn.getline(vim.v.foldend)
  local end_ = vim.trim(end_str)
  local result = {}
  fold_virt_text(result, start, vim.v.foldstart - 1)
  table.insert(result, { " ... ", "Delimiter" })
  fold_virt_text(result, end_, vim.v.foldend - 1, #(end_str:match("^(%s+)") or ""))
  return result
end

---Cycle through words (true -> false, on -> off)
---@param decrement boolean?
function M.word_cycle(decrement)
  local toggle_groups = {
    { "true", "false" },
    { "on", "off" },
    { "now", "later" },
  }

  local function match_case(original, new)
    if original:match("^%u+$") then
      return new:upper()
    end
    if original:match("^%l+$") then
      return new:lower()
    end
    if original:match("^%u%l+$") then
      return new:sub(1, 1):upper() .. new:sub(2):lower()
    end
    return new
  end

  local function get_next_word(word)
    local lower = word:lower()
    for _, group in ipairs(toggle_groups) do
      for i, w in ipairs(group) do
        if w == lower then
          local swap = group[(i % #group) + (decrement and -1 or 1)]
          return match_case(word, swap)
        end
      end
    end
    return nil
  end

  local word = vim.fn.expand("<cword>")
  local replacement = get_next_word(word)
  if not replacement then
    return
  end

  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  local start_col = col
  while start_col > 0 and line:sub(start_col, start_col):match("[%w_]") do
    start_col = start_col - 1
  end
  start_col = start_col + 1

  local end_col = col + 1
  while line:sub(end_col, end_col):match("[%w_]") do
    end_col = end_col + 1
  end
  end_col = end_col - 1

  local new_line = line:sub(1, start_col - 1) .. replacement .. line:sub(end_col + 1)
  vim.api.nvim_set_current_line(new_line)
end

---@param config {type?:string, args?:string[]|fun():string[]?}
function M.dap_get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
  local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
    if config.type and config.type == "java" then
      ---@diagnostic disable-next-line: return-type-mismatch
      return new_args
    end
    return require("dap.utils").splitstr(new_args)
  end
  return config
end

return M
