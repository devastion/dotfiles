vim.pack.add({
  'https://github.com/hat0uma/csvview.nvim',
}, { confirm = false })

local csvview = require('csvview')

csvview.setup({
  parser = {
    comments = { '#', '//' },
  },
  keymaps = {
    textobject_field_inner = { 'iF', mode = { 'o', 'x' } },
    textobject_field_outer = { 'aF', mode = { 'o', 'x' } },

    jump_next_field_end = { '<Tab>', mode = { 'n', 'x' } },
    jump_prev_field_end = { '<S-Tab>', mode = { 'n', 'x' } },

    jump_next_row = { '<Enter>', mode = { 'n', 'x' } },
    jump_prev_row = { '<S-Enter>', mode = { 'n', 'x' } },
  },
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('devastion.csvview', { clear = true }),
  pattern = { 'csv', 'tsv' },
  callback = function(args)
    csvview.enable(args.buf)

    vim.keymap.set('n', '<leader>uV', function()
      csvview.toggle()
    end, {
      desc = 'Toggle CSV view',
      buffer = args.buf,
    })
  end,
  desc = 'Enable csvview and buffer-local toggle for CSV/TSV',
})
