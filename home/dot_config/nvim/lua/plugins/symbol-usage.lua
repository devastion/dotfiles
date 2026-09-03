vim.pack.add({
  'https://github.com/Wansmer/symbol-usage.nvim',
}, { confirm = false })

require('symbol-usage').setup({
  vt_position = 'end_of_line',
})
