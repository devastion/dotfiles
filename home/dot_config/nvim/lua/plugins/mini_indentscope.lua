vim.pack.add({
  'https://github.com/nvim-mini/mini.indentscope',
}, { confirm = false })

local mini_indentscope = require('mini.indentscope')

mini_indentscope.setup({
  draw = {
    delay = 50,
    animation = mini_indentscope.gen_animation.none(),
  },
  symbol = '╎',
  options = {
    try_as_border = true,
  },
  mappings = {
    object_scope = 'ii',
    object_scope_with_border = 'ai',
    goto_top = '[i',
    goto_bottom = ']i',
  },
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup(
    'devastion.indentscope',
    { clear = true }
  ),
  pattern = {
    'checkhealth',
    'fzf',
    'gitcommit',
    'help',
    'markdown',
    'minifiles',
    'starter',
    'text',
  },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
  desc = 'Disable indentscope',
})
