vim.pack.add({
  'https://github.com/monaqa/dial.nvim',
}, { confirm = false })

---@param increment boolean
---@param g? boolean
local function dial(increment, g)
  local mode = vim.fn.mode(true)
  local is_visual = mode == 'v' or mode == 'V' or mode == '\22'
  local func = (increment and 'inc' or 'dec')
    .. (g and '_g' or '_')
    .. (is_visual and 'visual' or 'normal')
  local group = vim.g.dials_by_ft[vim.bo.filetype] or 'default'
  return require('dial.map')[func](group)
end

vim.keymap.set({ 'n', 'v' }, '<c-a>', function()
  return dial(true)
end, { desc = 'Increment', expr = true })
vim.keymap.set({ 'n', 'v' }, '<c-x>', function()
  return dial(false)
end, { desc = 'Decrement', expr = true })
vim.keymap.set({ 'n', 'x' }, 'g<c-a>', function()
  return dial(true, true)
end, { desc = 'Increment', expr = true })
vim.keymap.set({ 'n', 'x' }, 'g<c-x>', function()
  return dial(false, true)
end, { desc = 'Decrement', expr = true })

local augend = require('dial.augend')

local logical_alias = augend.constant.new({
  elements = { '&&', '||' },
  word = false,
  cyclic = true,
})

local ordinal_numbers = augend.constant.new({
  elements = {
    'first',
    'second',
    'third',
    'fourth',
    'fifth',
    'sixth',
    'seventh',
    'eighth',
    'ninth',
    'tenth',
  },
  word = false,
  cyclic = true,
})
local weekdays = augend.constant.new({
  elements = {
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  },
  word = true,
  cyclic = true,
})
local months = augend.constant.new({
  elements = {
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  },
  word = true,
  cyclic = true,
})
local capitalized_boolean = augend.constant.new({
  elements = {
    'True',
    'False',
  },
  word = true,
  cyclic = true,
})
local enable_disable = augend.constant.new({
  elements = {
    'enable',
    'disable',
  },
  word = true,
  cyclic = true,
})
local on_off = augend.constant.new({
  elements = {
    'on',
    'off',
  },
  word = true,
  cyclic = true,
})
local yes_no = augend.constant.new({
  elements = {
    'yes',
    'no',
  },
  word = true,
  cyclic = true,
})
local allow_deny = augend.constant.new({
  elements = {
    'allow',
    'deny',
  },
  word = true,
  cyclic = true,
})
local casing = augend.case.new({
  types = { 'camelCase', 'snake_case', 'PascalCase', 'SCREAMING_SNAKE_CASE' },
  cyclic = true,
})
local dial_opts = {
  dials_by_ft = {
    css = 'css',
    vue = 'vue',
    javascript = 'typescript',
    typescript = 'typescript',
    typescriptreact = 'typescript',
    javascriptreact = 'typescript',
    json = 'json',
    lua = 'lua',
    markdown = 'markdown',
    sass = 'css',
    scss = 'css',
    python = 'python',
    php = 'php',
  },
  groups = {
    default = {
      augend.integer.alias.decimal,
      augend.integer.alias.decimal_int,
      augend.integer.alias.hex,
      augend.date.alias['%Y/%m/%d'],
      ordinal_numbers,
      weekdays,
      months,
      capitalized_boolean,
      augend.constant.alias.bool,
      logical_alias,
      enable_disable,
      on_off,
      yes_no,
      allow_deny,
      casing,
    },
    vue = {
      augend.constant.new({ elements = { 'let', 'const' } }),
      augend.hexcolor.new({ case = 'lower' }),
      augend.hexcolor.new({ case = 'upper' }),
    },
    typescript = {
      augend.constant.new({ elements = { 'let', 'const' } }),
    },
    css = {
      augend.hexcolor.new({
        case = 'lower',
      }),
      augend.hexcolor.new({
        case = 'upper',
      }),
    },
    markdown = {
      augend.constant.new({
        elements = { '[ ]', '[x]' },
        word = false,
        cyclic = true,
      }),
      augend.misc.alias.markdown_header,
    },
    json = {
      augend.semver.alias.semver,
    },
    lua = {
      augend.constant.new({
        elements = { 'and', 'or' },
        word = true,
        cyclic = true,
      }),
    },
    python = {
      augend.constant.new({
        elements = { 'and', 'or' },
      }),
    },
    php = {
      augend.constant.new({
        elements = {
          'public',
          'private',
          'protected',
        },
        word = true,
        cyclic = true,
      }),
    },
  },
}

for name, group in pairs(dial_opts.groups) do
  if name ~= 'default' then vim.list_extend(group, dial_opts.groups.default) end
end
require('dial.config').augends:register_group(dial_opts.groups)
vim.g.dials_by_ft = dial_opts.dials_by_ft
