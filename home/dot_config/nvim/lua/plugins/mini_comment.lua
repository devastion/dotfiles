vim.pack.add({
  'https://github.com/nvim-mini/mini.comment',
  'https://github.com/JoosepAlviste/nvim-ts-context-commentstring',
}, { confirm = false })

require('mini.comment').setup({
  options = {
    custom_commentstring = function()
      return require('ts_context_commentstring').calculate_commentstring()
        or vim.bo.commentstring
    end,
  },
})
