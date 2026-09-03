vim.pack.add({
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/folke/noice.nvim',
}, { confirm = false })

local map = vim.keymap.set
local icons = require('config.icons')

local noice = require('noice')

noice.setup({
  views = {
    cmdline_popup = {
      position = {
        row = 10,
        col = '50%',
      },
      size = {
        min_width = 60,
        width = 'auto',
        height = 'auto',
      },
    },
  },
  cmdline = {
    enabled = true,
    view = 'cmdline_popup',
    format = {
      cmdline = {
        pattern = '^:',
        icon = icons.filetype('vim'),
        lang = 'vim',
        title = 'Cmdline',
      },
      print = {
        pattern = '^:=',
        icon = icons.filetype('lua'),
        lang = 'lua',
        title = 'Print',
      },
      search_down = {
        kind = 'search',
        pattern = '^/',
        icon = icons.filetype('regex') .. ' ' .. icons.ui('down'),
        lang = 'regex',
        title = 'Search',
      },
      search_up = {
        kind = 'search',
        pattern = '^%?',
        icon = icons.filetype('regex') .. ' ' .. icons.ui('up'),
        lang = 'regex',
        title = 'Search',
      },
      filter = {
        pattern = '^:%s*!',
        icon = icons.filetype('bash'),
        lang = 'bash',
        title = 'Filter',
      },
      lua = {
        pattern = '^:%s*lua%s+',
        icon = icons.filetype('lua'),
        lang = 'lua',
        title = 'Lua',
      },
      help = {
        pattern = '^:%s*he?l?p?%s+',
        icon = icons.filetype('help'),
        title = 'Help',
      },
      input = {
        view = 'cmdline_popup',
        icon = icons.ui('keyboard'),
        lang = 'text',
        title = '',
      },
    },
  },
  input = { enabled = false },
  confirm = { enabled = false },
  messages = {
    enabled = true,
    view = 'mini',
    view_error = 'mini',
    view_warn = 'mini',
    view_history = 'messages',
    view_search = 'virtualtext',
  },
  popupmenu = { enabled = false },
  lsp = {
    progress = { enabled = true },
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = false,
      ['vim.lsp.util.stylize_markdown'] = false,
      ['cmp.entry.get_documentation'] = false,
    },
    hover = { enabled = false },
    signature = { enabled = false },
    message = { enabled = false },
  },
  presets = {
    bottom_search = false,
    command_palette = false,
    long_message_to_split = false,
    inc_rename = false,
    lsp_doc_border = false,
  },
  notify = { enabled = true },
  routes = {
    {
      filter = {
        event = 'msg_show',
        any = {
          { find = '%d+L, %d+B' },
          { find = '; after #%d+' },
          { find = '; before #%d+' },
          { find = '%d fewer lines' },
          { find = '%d more lines' },
          { find = 'No information available' },
        },
      },
      opts = { skip = true },
    },
    {
      filter = { event = 'msg_showmode' },
      opts = { skip = true },
    },
  },
  format = {
    level = {
      icons = {
        error = icons.lsp('error'),
        warn = icons.lsp('warn'),
        info = icons.lsp('info'),
      },
    },
  },
  redirect = { view = 'popup', filter = { event = 'msg_show' } },
  commands = {
    history = {
      view = 'popup',
      opts = { enter = true, format = 'details' },
      filter = {
        any = {
          { event = 'notify' },
          { error = true },
          { warning = true },
          { event = 'msg_show', kind = { '' } },
          { event = 'lsp', kind = 'message' },
        },
      },
    },
    last = {
      view = 'popup',
      opts = { enter = true, format = 'details' },
      filter = {
        any = {
          { event = 'notify' },
          { error = true },
          { warning = true },
          { event = 'msg_show', kind = { '' } },
          { event = 'lsp', kind = 'message' },
        },
      },
      filter_opts = { count = 1 },
    },
    errors = {
      view = 'popup',
      opts = { enter = true, format = 'details' },
      filter = { error = true },
      filter_opts = { reverse = true },
    },
    all = {
      view = 'popup',
      opts = { enter = true, format = 'details' },
      filter = {},
      filter_opts = { reverse = true },
    },
  },
})

map('n', '<leader>na', function()
  noice.cmd('all')
end, { desc = 'Noice all' })
map('n', '<leader>nh', function()
  noice.cmd('history')
end, { desc = 'Noice history' })
map('n', '<leader>nl', function()
  noice.cmd('last')
end, { desc = 'Noice last message' })
map('n', '<leader>nd', function()
  noice.cmd('dismiss')
end, { desc = 'Dismiss notifications' })
map('n', '<leader>ne', function()
  noice.cmd('errors')
end, { desc = 'Noice errors' })
map('n', '<leader>nf', function()
  noice.cmd('fzf')
end, { desc = 'Noice history (fzf)' })

map('c', '<M-CR>', function()
  noice.redirect(vim.fn.getcmdline())
end, { desc = 'Redirect cmdline' })

require('which-key').add({ '<leader>n', group = 'Notification' })
