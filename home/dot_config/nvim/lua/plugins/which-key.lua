vim.pack.add({ 'https://github.com/folke/which-key.nvim' }, { confirm = false })

local icons = require('config.icons')

local which_key = require('which-key')

which_key.setup({
  preset = 'helix',
  delay = 0,
  defer = nil,
  triggers = {
    { '<auto>', mode = 'nixsotc' },
    { 's', mode = { 'n', 'x' } },
  },
  expand = function(node)
    return not node.desc
  end,
  win = {
    no_overlap = false,
  },
  keys = {
    scroll_down = '<C-d>',
    scroll_up = '<C-u>',
  },
  icons = {
    breadcrumb = '󰄾',
    separator = '',
    group = '',
    ellipsis = '',
    keys = {
      Space = ' ',
    },
  },
  sort = { 'group', 'alphanum' },
})

which_key.add({
  { '<leader><tab>', group = 'Tabs', icon = '󰌒 ' },
  {
    '<leader>?',
    function()
      require('which-key').show({ global = true })
    end,
    desc = 'Buffer Local Keymaps (which-key)',
  },
  { '<leader>F', group = 'File Operations', icon = '󱌣' },
  { '<leader>a', group = 'AI', mode = { 'n', 'x' } },
  {
    '<leader>b',
    group = 'Buffers',
    expand = function()
      return require('which-key.extras').expand.buf()
    end,
  },
  { '<leader>c', group = 'Code', mode = { 'n', 'x' } },
  { '<leader>d', group = 'Debug', mode = { 'n', 'x' } },
  { '<leader>f', group = 'Files', mode = { 'n', 'x' } },
  { '<leader>A', group = 'Anchor', mode = { 'n' }, icon = icons.ui.anchor },
  { '<leader>g', group = 'Git', mode = { 'n', 'x' } },
  {
    '<leader>gh',
    group = 'Hunks',
    mode = { 'n', 'x' },
    icon = icons.git.change,
  },
  { '<leader>gu', group = 'Toggles', icon = icons.ui.switch },
  { '<leader>h', group = 'Anchor' },
  { '<leader>q', group = 'Session' },
  { '<leader>r', group = 'Refactor', mode = { 'n', 'x' } },
  { '<leader>s', group = 'Search', mode = { 'n', 'x' } },
  { '<leader>u', group = 'Toggles', icon = icons.ui.switch },
  { '<leader>y', group = 'Yank', icon = '󱉧' },
  { '<', group = 'Swap Previous', mode = 'n' },
  { '>', group = 'Swap Next', mode = 'n' },
  { '[', group = 'Prev', mode = { 'n', 'x', 'o' } },
  { ']', group = 'Next', mode = { 'n', 'x', 'o' } },
  { 'g', group = 'Goto' },
  { 'gc', group = 'Comment', mode = { 'n', 'o' }, icon = icons.ui.comment },
  { 'gr', group = 'LSP', icon = icons.ui.lsp },
  { 's', group = 'Operators' },
  { 'z', group = 'Fold' },
})
