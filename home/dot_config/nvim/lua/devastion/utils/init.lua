local M = {}

---Remap keymap
---@param lhs string
---@param rhs string|function
---@param desc string?
---@param mode string|string[]?
---@param opts vim.keymap.set.Opts?
function M.map(lhs, rhs, desc, mode, opts)
  opts = opts or {}
  opts.desc = desc
  mode = mode or "n"

  vim.keymap.set(mode, lhs, rhs, opts)
end

M.autocmd = vim.api.nvim_create_autocmd

---Create augroup prefixed with "user_" prefix
---@param name string
---@return number
function M.augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

M.usercmd = vim.api.nvim_create_user_command

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

---Safe require: logs errors as notifications instead of crashing the config,
---so one broken module doesn't prevent the rest from loading.
---@param mod string
function M.safe_require(mod)
  local ok, result = pcall(require, mod)
  if not ok then
    vim.schedule(function()
      vim.notify("Failed to load " .. mod .. "\n" .. result, vim.log.levels.ERROR)
    end)
  end
  return result
end

--Better foldtext
---@return table
function M.foldtext()
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

---Check if a command-line tool exists
---@param cmd string The command to check
---@return boolean: True if the command exists, false otherwise
function M.cmd_exists(cmd)
  if not cmd or cmd == "" then
    return false
  end

  return vim.fn.executable(cmd) == 1
end

return M
