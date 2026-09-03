local opt_local = vim.opt_local

opt_local.buflisted = false
opt_local.number = false
opt_local.relativenumber = false
opt_local.signcolumn = 'auto'
opt_local.winfixheight = true
opt_local.wrap = false

local map = vim.keymap.set
local function default_opts(desc)
  return {
    buf = 0,
    desc = desc,
    silent = true,
  }
end

map('n', 'dd', function()
  local idx = vim.fn.line('.')
  local is_loc = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].loclist
    == 1
  local get = is_loc and function()
    return vim.fn.getloclist(0)
  end or vim.fn.getqflist
  local items = get()
  table.remove(items, idx)
  if is_loc then
    vim.fn.setloclist(0, items, 'r')
  else
    vim.fn.setqflist(items, 'r')
  end
  vim.api.nvim_win_set_cursor(0, { math.min(idx, math.max(#items, 1)), 0 })
end, default_opts('Delete entry'))
