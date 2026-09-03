vim.pack.add(
  { 'https://github.com/brenoprata10/nvim-highlight-colors' },
  { confirm = false }
)

require('nvim-highlight-colors').setup({
  render = 'virtual',
  virtual_symbol = '',
  names = false,
  rgb_fn = true,
  hsl_fn = true,
})
