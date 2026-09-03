vim.pack.add({
  'https://github.com/lewis6991/async.nvim',
  'https://github.com/ThePrimeagen/refactoring.nvim',
}, { confirm = false })

require('refactoring').setup({
  refactor = {
    inline_var = {
      code_generation = {
        group_expression = {
          lua = function(opts)
            return opts.expression
          end,
        },
      },
    },
  },
})

local map = vim.keymap.set

map({ 'n', 'x' }, '<leader>rr', function()
  require('refactoring').select_refactor()
end, { desc = 'Refactor' })

map({ 'n', 'x' }, '<leader>rf', function()
  return require('refactoring').extract_func()
end, { desc = 'Extract Function', expr = true })

map({ 'n', 'x' }, '<leader>rv', function()
  return require('refactoring').extract_var()
end, { desc = 'Extract Variable', expr = true })

map({ 'n', 'x' }, '<leader>rF', function()
  return require('refactoring').inline_func()
end, { desc = 'Inline function', expr = true })

map({ 'n', 'x' }, '<leader>rV', function()
  return require('refactoring').inline_var()
end, { desc = 'Inline Variable', expr = true })

map('n', '<leader>rp', function()
  return require('refactoring.debug').print_var({ output_location = 'below' })
    .. 'iw'
end, { desc = 'Debug print var below', expr = true })

map('x', '<leader>rp', function()
  return require('refactoring.debug').print_var({ output_location = 'below' })
end, { desc = 'Debug print var below', expr = true })

map('n', '<leader>rP', function()
  return require('refactoring.debug').print_var({ output_location = 'above' })
    .. 'iw'
end, { desc = 'Debug print var above', expr = true })

map('x', '<leader>rP', function()
  return require('refactoring.debug').print_var({ output_location = 'above' })
end, { desc = 'Debug print var above', expr = true })

map({ 'x', 'n' }, '<leader>re', function()
  return require('refactoring.debug').print_exp({ output_location = 'below' })
end, { desc = 'Debug print exp below', expr = true })

map({ 'x', 'n' }, '<leader>rE', function()
  return require('refactoring.debug').print_exp({ output_location = 'above' })
end, { desc = 'Debug print exp above', expr = true })

map('n', '<leader>rD', function()
  return require('refactoring.debug').print_loc({ output_location = 'above' })
end, { desc = 'Debug print location', expr = true })

map('n', '<leader>rd', function()
  return require('refactoring.debug').print_loc({ output_location = 'below' })
end, { desc = 'Debug print location', expr = true })

map({ 'x', 'n' }, '<leader>rc', function()
  return require('refactoring.debug').cleanup({ restore_view = true }) .. 'ag'
end, { desc = 'Debug print clean', expr = true, remap = true })
