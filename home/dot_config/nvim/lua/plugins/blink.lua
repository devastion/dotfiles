---@return boolean
local function has_words_before()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  if col == 0 then return false end
  local line = vim.api.nvim_get_current_line()
  return line:sub(col, col):match('%s') == nil
end

local function get_mini_icon(ctx)
  local data = type(ctx.item.data) == 'table' and ctx.item.data or nil
  if ctx.source_name == 'Path' and data and type(data.type) == 'string' then
    local is_unknown_type = vim.tbl_contains(
      { 'link', 'socket', 'fifo', 'char', 'block', 'unknown' },
      data.type
    )
    local category = is_unknown_type and 'os' or data.type
    local name = is_unknown_type and '' or (data.path or ctx.label)
    if type(name) == 'string' then
      local mini_icon, mini_hl = require('mini.icons').get(category, name)
      if mini_icon then return mini_icon, mini_hl end
    end
  end

  local kind = type(ctx.kind) == 'string' and ctx.kind ~= '' and ctx.kind
    or 'File'
  return require('mini.icons').get('lsp', kind)
end

vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('devastion.blink', { clear = true }),
  desc = 'Build blink.cmp on install or update',
  callback = function(args)
    local name, kind = args.data.spec.name, args.data.kind
    local path = args.data.path

    if name ~= 'blink.cmp' then return end
    if kind ~= 'install' and kind ~= 'update' then return end
    if not args.data.active then vim.cmd.packadd('blink.cmp') end

    vim.notify('Building blink.cmp', vim.log.levels.INFO)

    vim.system({ 'cargo', 'build', '--release' }, { cwd = path }, function(obj)
      vim.schedule(function()
        if obj.code == 0 then
          vim.notify('Building blink.cmp done', vim.log.levels.INFO)
        else
          vim.notify(
            ('Building blink.cmp failed\n%s'):format(obj.stderr or ''),
            vim.log.levels.ERROR
          )
        end
      end)
    end)
  end,
})

vim.pack.add({
  {
    src = 'https://github.com/saghen/blink.cmp',
    version = vim.version.range('1.*'),
  },
  'https://github.com/rafamadriz/friendly-snippets',
}, { confirm = false })

vim.api.nvim_create_autocmd({ 'InsertEnter', 'CmdlineEnter' }, {
  group = vim.api.nvim_create_augroup(
    'devastion.blink_setup',
    { clear = true }
  ),
  desc = 'Configure blink.cmp on first use',
  once = true,
  callback = function()
    require('blink.cmp').setup({
      keymap = {
        preset = 'none',
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-n>'] = { 'show', 'select_next', 'fallback' },
        ['<C-p>'] = { 'show', 'select_prev', 'fallback' },
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-s>'] = { 'show_signature', 'hide_signature', 'fallback' },
        ['<esc>'] = {
          function(cmp)
            if cmp.is_visible() and cmp.get_selected_item() ~= nil then
              return cmp.cancel()
            else
              return
            end
          end,
          'fallback',
        },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<Tab>'] = {
          'snippet_forward',
          'select_next',
          function(cmp)
            if has_words_before() then return cmp.show() end
          end,
          'fallback',
        },
        ['<S-Tab>'] = {
          'snippet_backward',
          'select_prev',
          'fallback',
        },
      },
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 0,
        },
        menu = {
          auto_show = function()
            local in_snippet = vim.snippet ~= nil
              and vim.snippet.active ~= nil
              and vim.snippet.active()
            return not in_snippet and vim.bo.buftype ~= 'terminal'
          end,
          draw = {
            columns = {
              { 'kind_icon' },
              { 'label', gap = 1 },
              { 'kind' },
            },
            components = {
              kind_icon = {
                text = function(ctx)
                  local kind_icon, _ = get_mini_icon(ctx)
                  return kind_icon
                end,
                highlight = function(ctx)
                  local _, hl = get_mini_icon(ctx)
                  return hl
                end,
              },
              kind = {
                highlight = function(ctx)
                  local _, hl = get_mini_icon(ctx)
                  return hl
                end,
              },
            },
          },
        },
      },
      signature = {
        enabled = true,
        trigger = { enabled = true },
      },
      appearance = {
        nerd_font_variant = 'mono',
      },
      fuzzy = {
        implementation = 'prefer_rust',
        sorts = { 'exact', 'score', 'sort_text', 'label' },
      },
      cmdline = {
        keymap = {
          preset = 'none',
          ['<CR>'] = { 'accept_and_enter', 'fallback' },
          ['<Tab>'] = {
            'show_and_insert',
            'select_next',
          },
          ['<S-tab>'] = { 'select_prev' },
          ['<c-space>'] = { 'show', 'fallback' },
          ['<c-n>'] = { 'select_next', 'fallback' },
          ['<c-p>'] = { 'select_prev', 'fallback' },
        },
        completion = {
          menu = { auto_show = true },
          list = {
            selection = {
              preselect = false,
              auto_insert = true,
            },
          },
        },
      },
      sources = {
        default = {
          'lsp',
          'buffer',
          'snippets',
          'path',
        },
        providers = {
          snippets = {
            opts = {
              friendly_snippets = true,
              global_snippets = { 'global' },
              extended_filetypes = {
                sh = { 'shelldoc' },
                bash = { 'shelldoc' },
                zsh = { 'shelldoc' },
                php = { 'phpdoc' },
              },
            },
          },
        },
      },
    })
  end,
})
