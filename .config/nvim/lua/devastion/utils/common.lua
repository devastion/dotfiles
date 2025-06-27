local M = {}

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

---Remap keymap
---@param lhs string
---@param rhs string|function
---@param desc string
---@param mode string|table
---@param opts table
function M.remap(lhs, rhs, desc, mode, opts)
  opts = opts or {}
  opts.desc = desc
  mode = mode or "n"
  vim.keymap.set(mode, lhs, rhs, opts)
end

function M.fold_virt_text(result, s, lnum, coloff)
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

function M.custom_foldtext()
  local start = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
  local end_str = vim.fn.getline(vim.v.foldend)
  local end_ = vim.trim(end_str)
  local result = {}
  M.fold_virt_text(result, start, vim.v.foldstart - 1)
  table.insert(result, { " ... ", "Delimiter" })
  M.fold_virt_text(result, end_, vim.v.foldend - 1, #(end_str:match("^(%s+)") or ""))
  return result
end

function M.toggles(decrement)
  local increment_toggles = {
    ["false"] = "true",
  }

  local decrement_toggles = {
    ["true"] = "false",
  }

  local toggles = decrement and decrement_toggles or increment_toggles

  local cword = vim.fn.expand("<cword>")
  local newWord

  for word, opposite in pairs(toggles) do
    if cword == word then
      newWord = opposite
    end
    if cword == opposite then
      newWord = word
    end
  end

  if type(tonumber(cword)) == "number" then
    newWord = decrement and (cword - 1) or (cword + 1)
  end

  if newWord then
    local prevCursor = vim.api.nvim_win_get_cursor(0)
    vim.cmd.normal({ '"_ciw' .. newWord, bang = true })
    vim.api.nvim_win_set_cursor(0, prevCursor)
  end
end

return M
