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

---Get all configurations in after/lsp/*
---@return string[]
function M.get_lsp_configs()
  local lsp_configs = {}

  for _, v in ipairs(vim.api.nvim_get_runtime_file("after/lsp/*", true)) do
    local name = vim.fn.fnamemodify(v, ":t:r")
    table.insert(lsp_configs, name)
  end

  return lsp_configs
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
    { "in", "out" },
    { "start", "stop" },
    { "show", "hide" },
    { "enable", "disable" },
    { "yes", "no" },
    { "up", "down" },
    { "always", "never" },
    { "error", "warn", "info", "debug", "trace" },
    { "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday" },
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

M.diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = "✘",
  [vim.diagnostic.severity.WARN] = "▲",
  [vim.diagnostic.severity.HINT] = "⚑",
  [vim.diagnostic.severity.INFO] = "»",
}

function M.get_attached_clients()
  -- Get active clients for current buffer
  local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
  if #buf_clients == 0 then
    return "No client active"
  end
  local buf_ft = vim.bo.filetype
  local buf_client_names = {}
  local num_client_names = #buf_client_names

  -- Add lsp-clients active in the current buffer
  for _, client in pairs(buf_clients) do
    num_client_names = num_client_names + 1
    buf_client_names[num_client_names] = client.name
  end

  -- Add linters for the current filetype (nvim-lint)
  local lint_success, lint = pcall(require, "lint")
  if lint_success then
    for ft, ft_linters in pairs(lint.linters_by_ft) do
      if ft == buf_ft then
        if type(ft_linters) == "table" then
          for _, linter in pairs(ft_linters) do
            num_client_names = num_client_names + 1
            buf_client_names[num_client_names] = linter
          end
        else
          num_client_names = num_client_names + 1
          buf_client_names[num_client_names] = ft_linters
        end
      end
    end
  end

  -- Add formatters (conform.nvim)
  local conform_success, conform = pcall(require, "conform")
  if conform_success then
    for _, formatter in pairs(conform.list_formatters_for_buffer(0)) do
      if formatter then
        num_client_names = num_client_names + 1
        buf_client_names[num_client_names] = formatter
      end
    end
  end

  local client_names_str = table.concat(buf_client_names, ", ")
  local language_servers = string.format("[%s]", client_names_str)

  return language_servers
end

return M
