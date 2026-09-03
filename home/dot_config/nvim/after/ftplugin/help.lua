local opt_local = vim.opt_local

opt_local.breakindent = true
opt_local.colorcolumn = ''
opt_local.cursorcolumn = false
opt_local.cursorline = true
opt_local.foldcolumn = '0'
opt_local.linebreak = true
opt_local.list = false
opt_local.number = false
opt_local.relativenumber = false
opt_local.showbreak = ''
opt_local.signcolumn = 'no'
opt_local.smoothscroll = true
opt_local.spell = false
opt_local.wrap = true

opt_local.buflisted = false
opt_local.modifiable = false
opt_local.modified = false
opt_local.textwidth = 78

local map = vim.keymap.set
local function default_opts(desc)
  return {
    buf = 0,
    desc = desc,
    silent = true,
  }
end

map('n', 'K', function()
  vim.cmd.help(vim.fn.expand('<cword>'))
end, default_opts('Help for word under cursor'))
map('n', '<CR>', '<C-]>', default_opts('Jump to help tag'))
map('n', '<BS>', '<C-T>', default_opts('Go back in help'))
map('n', 'gd', '<C-]>', default_opts('Jump to help tag'))
