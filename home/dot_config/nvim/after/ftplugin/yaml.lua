local opt_local = vim.opt_local

opt_local.shiftwidth = 2
opt_local.indentkeys:remove('0#')
opt_local.indentkeys:remove('<:>')
opt_local.foldmethod = 'indent'
opt_local.foldlevel = 3
