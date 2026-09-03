vim.pack.add({
  'https://github.com/nvim-mini/mini.operators',
}, { confirm = false })

local mini_operators = require('mini.operators')

mini_operators.setup({
  evaluate = {
    prefix = '',
    func = nil,
  },
  exchange = {
    prefix = '',
    reindent_linewise = true,
  },
  multiply = {
    prefix = '',
    func = nil,
  },
  replace = {
    prefix = '',
    reindent_linewise = true,
  },
  sort = {
    prefix = '',
    func = nil,
  },
})

mini_operators.make_mappings(
  'evaluate',
  { textobject = 's=', line = 's+', selection = 's=' }
)
mini_operators.make_mappings(
  'exchange',
  { textobject = 'sx', line = 'sX', selection = 'sx' }
)
mini_operators.make_mappings(
  'multiply',
  { textobject = 'sm', line = 'sM', selection = 'sM' }
)
mini_operators.make_mappings(
  'replace',
  { textobject = 'ss', line = 'sS', selection = 'ss' }
)
mini_operators.make_mappings(
  'sort',
  { textobject = 'so', line = 'sO', selection = 'so' }
)
