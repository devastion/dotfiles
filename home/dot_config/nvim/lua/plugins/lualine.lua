vim.pack.add({
  'https://github.com/nvim-lualine/lualine.nvim',
}, { confirm = false })

local icons = require('config.icons')

local function wordcount()
  local wc = vim.fn.wordcount()
  local visual_words = wc.visual_words or wc.words
  local word_string = visual_words == 1 and 'word' or 'words'
  local reading_time = math.ceil(visual_words / 200.0) .. ' min'
  return string.format(
    '%s %s (%s)',
    tostring(visual_words),
    word_string,
    reading_time
  )
end

local text_filetypes = {
  markdown = true,
  asciidoc = true,
  pandoc = true,
  tex = true,
  text = true,
}
local function is_textfile()
  return text_filetypes[vim.bo.filetype] == true
end

---@class FileStat
---@field name string
---@field exec boolean
---@field writable boolean
---@field perm string

---@param buf integer
local function sample_file_stat(buf)
  local fname = vim.api.nvim_buf_get_name(buf)
  if fname == '' or vim.bo[buf].buftype ~= '' then
    vim.b[buf].file_stat = nil
    return
  end

  vim.b[buf].file_stat = {
    name = fname,
    exec = vim.fn.executable(fname) == 1,
    writable = vim.fn.filewritable(fname) == 1,
    perm = vim.fn.getfperm(fname),
  }
end

vim.api.nvim_create_autocmd(
  { 'BufEnter', 'BufWritePost', 'FileChangedShellPost', 'FocusGained' },
  {
    group = vim.api.nvim_create_augroup('devastion.lualine_filestat', {
      clear = true,
    }),
    callback = function(args)
      sample_file_stat(args.buf)
    end,
    desc = 'Sample file permissions for the statusline',
  }
)

---@return FileStat?
local function file_stat()
  return vim.b.file_stat
end

---@param group string
---@param fallback string
---@return string
local function hl_fg(group, fallback)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if not ok or not hl or not hl.fg then return fallback end
  return ('#%06x'):format(hl.fg)
end

---@type table<string, string>
local palette = {}

local function refresh_palette()
  palette = {
    modified = hl_fg('DiagnosticWarn', '#ff9e64'),
    exec = hl_fg('DiagnosticError', '#f7768e'),
    writable = hl_fg('DiagnosticOk', '#9ece6a'),
    muted = hl_fg('Comment', '#565f89'),
  }
end
refresh_palette()

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('devastion.lualine_palette', {
    clear = true,
  }),
  desc = 'Re-sample statusline colours from the colorscheme',
  callback = refresh_palette,
})

---@param opts? { include_writable?: boolean }
---@return table
local function file_status_color(opts)
  opts = opts or {}
  local stat = file_stat()
  if not stat then return {} end
  if vim.bo.modified then return { fg = palette.modified } end
  if stat.exec then return { fg = palette.exec } end
  if stat.writable then
    return opts.include_writable and { fg = palette.writable } or {}
  end
  return { fg = palette.muted }
end

local function lint_progress()
  local linters = require('lint').get_running()
  if #linters == 0 then return '' end
  return '󰑐 ' .. table.concat(linters, ', ')
end

local function available_tools()
  local lsp = vim
    .iter(vim.lsp.get_clients({ bufnr = 0 }))
    :map(function(lsp_client)
      return lsp_client.name
    end)
    :totable()
  local linters = require('lint').linters_by_ft[vim.bo.filetype]
  local formatters = vim
    .iter(require('conform').list_formatters(0))
    :map(function(formatter)
      return formatter.name
    end)
    :totable()

  return table.concat(linters, icons.ui('small_dot', 'both'))
    .. icons.ui('small_dot', 'both')
    .. table.concat(formatters, icons.ui('small_dot', 'both'))
    .. icons.ui('small_dot', 'both')
    .. table.concat(lsp, icons.ui('small_dot', 'both'))
end

local options = {
  theme = 'auto',
  globalstatus = true,
  component_separators = { left = '', right = '' },
  section_separators = { left = '', right = '' },
  disabled_filetypes = {
    statusline = {},
    winbar = {
      'dap-repl',
      'dap-view',
      'dap-view-help',
      'dap-view-term',
      'gitcommit',
      'help',
      'noice',
      'pager',
      'qf',
    },
  },
}

local winbar = {
  lualine_a = {},
  lualine_b = {},
  lualine_c = {
    {
      'filetype',
      icon_only = true,
      separator = '',
      padding = { left = 1, right = 0 },
    },
    {
      'filename',
      path = 4,
      symbols = {
        created = '󰈙',
        modified = '',
        newfile = '󰈔',
        not_saved = '',
        readonly = '󰌾',
        unnamed = '󰈔',
      },
      color = function()
        return file_status_color()
      end,
    },
    {
      wordcount,
      cond = is_textfile,
    },
    {
      lint_progress,
      cond = function()
        local ok, lint = pcall(require, 'lint')
        return ok
          and lint.linters_by_ft[vim.bo.filetype]
          and #lint.linters_by_ft[vim.bo.filetype] > 0
      end,
      color = function()
        return { fg = palette.modified }
      end,
    },
    'selectioncount',
  },
  lualine_x = {
    available_tools,
  },
  lualine_y = {},
  lualine_z = {
    {
      'tabs',
      show_modified_status = false,
    },
  },
}

local opts = {
  options = options,
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {
      'branch',
    },
    lualine_c = {
      {
        'diagnostics',
        symbols = {
          debug = icons.lsp('debug', 'right'),
          error = icons.lsp('error', 'right'),
          hint = icons.lsp('hint', 'right'),
          info = icons.lsp('info', 'right'),
          off = icons.ui('close', 'right'),
          ok = icons.ui('check', 'right'),
          other = icons.lsp('other', 'right'),
          prefix = icons.ui('dot', 'right'),
          trace = icons.lsp('trace', 'right'),
          warn = icons.lsp('warn', 'right'),
        },
      },
    },
    lualine_x = {
      {
        'diff',
        symbols = {
          add = '',
          added = '󰐕',
          branch = '',
          change = '',
          conflict = '',
          delete = '',
          ignore = '',
          ignored = '',
          modified = '',
          removed = '󰍴',
          renamed = '󰁕',
          line_add = '▕▏',
          line_change = '▕▏',
          line_delete = '▁▁',
          status_add = '+',
          status_change = '~',
          status_delete = '-',
          sign_untracked = '?',
          repo = '',
          staged = '',
          stash = '󰆼',
          tag = '󰓹',
          unstaged = '󰄱',
          untracked = '󰐗',
        },
        source = function()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added,
              modified = gitsigns.changed,
              removed = gitsigns.removed,
            }
          end
        end,
      },
      {
        function()
          local stat = file_stat()
          return stat and stat.perm or ''
        end,
        color = function()
          return file_status_color({ include_writable = true })
        end,
        cond = function()
          return file_stat() ~= nil
        end,
      },
      'encoding',
      {
        'fileformat',
        icons_enabled = true,
        symbols = {
          unix = 'LF',
          dos = 'CRLF',
          mac = 'CR',
        },
      },
      'filetype',
    },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },

  winbar = winbar,

  inactive_winbar = vim.deepcopy(winbar),
}

require('lualine').setup(opts)
