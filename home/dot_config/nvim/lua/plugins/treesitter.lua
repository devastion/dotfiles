local group =
  vim.api.nvim_create_augroup('devastion.treesitter', { clear = true })

local function rebuild_parsers()
  require('nvim-treesitter')
    .update('all', { generate = true, max_jobs = 8 })
    :await(vim.schedule_wrap(function(err)
      if err then
        vim.notify(
          'Parser update failed: ' .. tostring(err),
          vim.log.levels.ERROR,
          { title = 'Treesitter' }
        )
        return
      end
      vim.notify(
        'Parsers up to date',
        vim.log.levels.INFO,
        { title = 'Treesitter' }
      )
    end))
end

vim.api.nvim_create_autocmd('PackChanged', {
  group = group,
  desc = 'Rebuild treesitter parsers on install or update',
  callback = function(args)
    local name, kind = args.data.spec.name, args.data.kind

    if
      name ~= 'nvim-treesitter' or (kind ~= 'install' and kind ~= 'update')
    then
      return
    end

    if not args.data.active then vim.cmd.packadd('nvim-treesitter') end

    vim.notify(
      'Rebuilding treesitter parsers',
      vim.log.levels.INFO,
      { title = 'Treesitter' }
    )
    rebuild_parsers()
  end,
})

vim.pack.add({
  {
    name = 'nvim-treesitter',
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    version = 'main',
  },
  {
    name = 'nvim-treesitter-textobjects',
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    version = 'main',
  },
  'https://github.com/RRethy/nvim-treesitter-endwise',
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
}, { confirm = false })

local ts = require('nvim-treesitter')

local ensure_installed = {
  'bash',
  'c',
  'diff',
  'dockerfile',
  'git_config',
  'git_rebase',
  'gitattributes',
  'gitcommit',
  'gitignore',
  'html',
  'javascript',
  'jsdoc',
  'json',
  'json5',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'regex',
  'ssh_config',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'xml',
  'yaml',
}

---@type table<string, true>
local installed = {}
---@type table<string, true>|nil
local available = nil

local function refresh_installed()
  installed = {}
  for _, lang in ipairs(ts.get_installed()) do
    installed[lang] = true
  end
end

---@param lang string
---@return boolean
local function is_available(lang)
  if available == nil then
    available = {}
    for _, l in ipairs(ts.get_available()) do
      available[l] = true
    end
  end
  return available[lang] == true
end

refresh_installed()

do
  local missing = vim
    .iter(ensure_installed)
    :filter(function(lang)
      return not installed[lang]
    end)
    :totable()

  if #missing > 0 then
    local ok, task = pcall(ts.install, missing, {
      generate = true,
      max_jobs = 8,
      summary = false,
    })
    if ok then
      vim.schedule(function()
        task:await(vim.schedule_wrap(refresh_installed))
      end)
    else
      vim.notify(
        'Parser installation failed to start: ' .. tostring(task),
        vim.log.levels.ERROR,
        { title = 'Treesitter' }
      )
    end
  end
end

require('nvim-treesitter-textobjects').setup({})

---@param direction 'next'|'previous'
---@param capture string
local function ts_move(direction, capture)
  if direction == 'next' then
    require('nvim-treesitter-textobjects.move').goto_next(
      capture,
      'textobjects'
    )
  end
  if direction == 'previous' then
    require('nvim-treesitter-textobjects.move').goto_previous(
      capture,
      'textobjects'
    )
  end
end

---@param capture string
local function ts_select(capture)
  require('nvim-treesitter-textobjects.select').select_textobject(
    capture,
    'textobjects'
  )
end

---@param direction 'next'|'previous'
---@param capture string
local function ts_swap(direction, capture)
  if direction == 'next' then
    require('nvim-treesitter-textobjects.swap').swap_next(
      capture,
      'textobjects'
    )
  end
  if direction == 'previous' then
    require('nvim-treesitter-textobjects.swap').swap_previous(
      capture,
      'textobjects'
    )
  end
end

local treesiter_moves = {
  f = '@function.outer',
  c = '@class.outer',
  a = '@parameter.outer',
  o = { '@block.outer', '@conditional.outer', '@loop.outer' },
  u = '@call.outer',
  A = '@assignment.outer',
  S = '@statement.outer',
  r = '@return.outer',
  C = '@comment.outer',
  s = '@string.outer',
}

local treesitter_swaps = {
  a = '@parameter.inner',
  f = '@function.outer',
  r = '@attribute.outer',
}

local treesitter_selects = {
  A = '@assignment.outer',
  C = '@comment.outer',
  S = '@statement.outer',
  a = '@parameter.outer',
  c = '@class.outer',
  f = '@function.outer',
  l = '@loop.outer',
  n = '@conditional.outer',
  o = '@block.outer',
  r = '@return.outer',
  s = '@string.outer',
  u = '@call.outer',
  ['`'] = '@codeblock.outer',
}

---@param bufnr integer
local function ts_textobjects_maps(bufnr)
  bufnr = bufnr or 0

  vim.iter(treesiter_moves):each(function(lhs, query)
    local function move(direction, native)
      return function()
        if lhs == 'c' and vim.wo.diff then
          return vim.cmd.normal({ native, bang = true })
        end
        ts_move(direction, query)
      end
    end

    vim.keymap.set('n', ']' .. lhs, move('next', ']c'), {
      buf = bufnr,
      desc = ('Next %s'):format(
        type(query) == 'string' and query or table.concat(query, ', ')
      ),
      silent = true,
    })

    vim.keymap.set('n', '[' .. lhs, move('previous', '[c'), {
      buf = bufnr,
      desc = ('Previous %s'):format(
        type(query) == 'string' and query or table.concat(query, ', ')
      ),
      silent = true,
    })
  end)

  vim.iter(treesitter_selects):each(function(lhs, query)
    local inner = (query:gsub('%.outer$', '.inner'))

    vim.keymap.set({ 'x', 'o' }, 'a' .. lhs, function()
      ts_select(query)
    end, {
      buf = bufnr,
      desc = ('Select %s'):format(query),
      silent = true,
    })

    vim.keymap.set({ 'x', 'o' }, 'i' .. lhs, function()
      ts_select(inner)
    end, {
      buf = bufnr,
      desc = ('Select %s'):format(inner),
      silent = true,
    })
  end)

  vim.iter(treesitter_swaps):each(function(lhs, query)
    vim.keymap.set('n', '>' .. lhs, function()
      ts_swap('next', query)
    end, {
      buf = bufnr,
      desc = ('Swap right %s'):format(query),
      silent = true,
    })

    vim.keymap.set('n', '<' .. lhs, function()
      ts_swap('previous', query)
    end, {
      buf = bufnr,
      desc = ('Swap left %s'):format(query),
      silent = true,
    })
  end)
end

---@param bufnr integer
---@param lang string
local function ts_attach(bufnr, lang)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  if not pcall(vim.treesitter.start, bufnr, lang) then return end

  if vim.treesitter.query.get(lang, 'folds') ~= nil then
    for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
      vim.api.nvim_win_call(win, function()
        vim.wo[0][0].foldmethod = 'expr'
        vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      end)
    end
  end

  if vim.treesitter.query.get(lang, 'indents') then
    vim.bo[bufnr].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
  end

  ts_textobjects_maps(bufnr)
end

---@type table<string, true>
local installing = {}

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  desc = 'Start treesitter, installing the parser on demand',
  callback = function(args)
    if vim.b[args.buf].large_file then
      pcall(vim.treesitter.stop, args.buf)
      return
    end

    local lang = vim.treesitter.language.get_lang(args.match) or args.match

    if installed[lang] then return ts_attach(args.buf, lang) end
    if not is_available(lang) or installing[lang] then return end

    installing[lang] = true

    local ok, task = pcall(
      ts.install,
      { lang },
      { generate = true, max_jobs = 8, summary = false }
    )
    if not ok then
      installing[lang] = nil
      return
    end

    task:await(vim.schedule_wrap(function(err)
      installing[lang] = nil
      if err then return end
      refresh_installed()
      if not installed[lang] then return end

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
          vim.api.nvim_buf_is_loaded(buf)
          and not vim.b[buf].large_file
          and (
              vim.treesitter.language.get_lang(vim.bo[buf].filetype)
              or vim.bo[buf].filetype
            )
            == lang
        then
          ts_attach(buf, lang)
        end
      end
    end))
  end,
})

require('treesitter-context').setup({
  max_lines = 3,
  min_window_height = 20,
  mode = 'topline',
  multiwindow = true,
})
