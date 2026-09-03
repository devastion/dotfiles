vim.pack.add({
  'https://github.com/kylechui/nvim-surround',
  'https://github.com/gregorias/nvim-surround-wk',
}, { confirm = false })

vim.g.nvim_surround_no_mappings = true
require('nvim-surround').setup()

vim.keymap.set(
  'n',
  'sa',
  '<Plug>(nvim-surround-normal)',
  { desc = 'Add surround' }
)
vim.keymap.set(
  'x',
  'sa',
  '<Plug>(nvim-surround-visual)',
  { desc = 'Add surround' }
)
vim.keymap.set(
  'n',
  'sd',
  '<Plug>(nvim-surround-delete)',
  { desc = 'Delete surround' }
)
vim.keymap.set(
  'n',
  'sr',
  '<Plug>(nvim-surround-change)',
  { desc = 'Change surround' }
)

require('nvim-surround-wk').setup()
