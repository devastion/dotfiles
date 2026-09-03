vim.pack.add({
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
}, { confirm = false })

require('render-markdown').setup({
  file_types = { 'markdown' },
  injections = {
    gitcommit = { enabled = true },
  },
  code = {
    enabled = true,
    width = 'block',
    min_width = 80,
    right_pad = 1,
    sign = false,
  },
  heading = {
    enabled = true,
    width = 'block',
    min_width = 80,
    right_pad = 1,
    sign = true,
  },
  completions = {
    lsp = {
      enabled = true,
    },
    blink = {
      enabled = true,
    },
  },
  bullet = {
    enabled = true,
    right_pad = 0,
  },
  latex = {
    enabled = false,
  },
})
