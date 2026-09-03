vim.pack.add({
  'https://github.com/nvim-mini/mini.align',
}, { confirm = false })

require('mini.align').setup({
  mappings = {
    start = 'ga',
    start_with_preview = 'gA',
  },
})
