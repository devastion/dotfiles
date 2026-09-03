vim.pack.add({
  'https://github.com/jeangiraldoo/codedocs.nvim',
}, { confirm = false })

vim.keymap.set('n', '<leader>cn', function()
  require('codedocs').generate()
end, { desc = 'Code Annotation' })
