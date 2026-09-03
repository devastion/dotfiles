local opt_local = vim.opt_local

opt_local.foldlevel = 1
opt_local.colorcolumn = '51,73'

opt_local.textwidth = 72

opt_local.iskeyword:append('-')

vim.api.nvim_win_set_cursor(0, { 1, 0 })
