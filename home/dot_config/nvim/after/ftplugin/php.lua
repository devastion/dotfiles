local opt_local = vim.opt_local

opt_local.iskeyword:append('$')
opt_local.path:append({
  'app/**',
  'resources/**',
  'routes/**',
})
opt_local.suffixesadd = '.php'

local map = vim.keymap.set
local function default_opts(desc)
  return {
    buf = 0,
    desc = desc,
    silent = true,
  }
end

map('n', '<leader>ci', function()
  vim.lsp.buf.code_action({
    context = { only = { 'source.organizeImports' }, diagnostics = {} },
    apply = true,
  })
end, default_opts('Organize imports'))
