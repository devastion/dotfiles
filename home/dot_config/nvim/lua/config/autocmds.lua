---@param name string
---@return integer
local function augroup(name)
  return vim.api.nvim_create_augroup(
    'devastion.config.' .. name,
    { clear = true }
  )
end

local default_group = augroup('default')

local autocmd = vim.api.nvim_create_autocmd

autocmd('TextYankPost', {
  group = default_group,
  desc = 'Highlight yanked text',
  callback = function()
    vim.hl.on_yank({
      timeout = 500,
      higroup = 'Visual',
    })
  end,
})

do
  local LARGE_FILE_BYTES = 1024 * 1024

  autocmd('BufReadPre', {
    group = default_group,
    desc = 'Flag large files so expensive features can opt out',
    callback = function(args)
      local name = vim.api.nvim_buf_get_name(args.buf)
      local ok, stat = pcall(vim.uv.fs_stat, name)
      local is_large_file = ok and stat and stat.size > LARGE_FILE_BYTES

      vim.b[args.buf].large_file = is_large_file

      if is_large_file then
        vim.opt_local.foldmethod = 'manual'
        vim.opt_local.spell = false
        vim.opt_local.swapfile = false
        vim.opt_local.syntax = 'off'
        vim.opt_local.undofile = false
      end
    end,
  })
end

autocmd({ 'FocusLost', 'BufLeave' }, {
  group = default_group,
  callback = function()
    if
      vim.bo.modified
      and vim.bo.buftype == ''
      and vim.api.nvim_buf_get_name(0) ~= ''
    then
      pcall(vim.cmd.write, { mods = { silent = true } })
    end
  end,
})

autocmd('FileType', {
  group = default_group,
  pattern = '*',
  callback = function()
    vim.opt_local.formatoptions:remove({ 'r', 'o' })
  end,
})

do
  local skipped = { 'gitcommit', 'gitrebase' }

  autocmd('BufReadPost', {
    group = default_group,
    desc = 'Restore cursor to last location',
    callback = function(args)
      local buf = args.buf

      if
        vim.tbl_contains(skipped, vim.bo[buf].filetype)
        or (vim.bo[buf].buftype ~= '' and not vim.bo[buf].buflisted)
      then
        return
      end

      local mark = vim.api.nvim_buf_get_mark(buf, '"')
      local lcount = vim.api.nvim_buf_line_count(buf)
      if mark[1] > 0 and mark[1] <= lcount then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
        vim.cmd.normal({ 'zz', bang = true })
      end
    end,
  })
end

autocmd('BufWritePre', {
  group = default_group,
  desc = 'Create missing parent directories',
  callback = function(args)
    if args.match:match('^%w%w+://') then return end
    local file = vim.uv.fs_realpath(args.match) or args.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

autocmd('FileType', {
  group = default_group,
  pattern = {
    'checkhealth',
    'grug-far',
    'help',
    'man',
    'nvim-pack',
    'qf',
    'query',
  },
  desc = 'Quit helper buffers with <q>',
  callback = function(args)
    local buf = args.buf

    vim.bo[buf].buflisted = false

    vim.keymap.set('n', 'q', function()
      vim.cmd.quit()
    end, { desc = 'Close buffer', buf = buf, silent = true })
  end,
})

do
  local qf_group = augroup('qf')
  -- autocmd(
  --   'QuickFixCmdPost',
  --   { group = qf_group, pattern = '[^l]*', command = 'cwindow' }
  -- )
  autocmd(
    'QuickFixCmdPost',
    { group = qf_group, pattern = 'l*', command = 'lwindow' }
  )
  autocmd('QuickFixCmdPost', {
    group = qf_group,
    pattern = { 'grep', 'grepadd', 'make', 'vimgrep' },
    desc = 'Open quickfix on grep results',
    callback = function()
      local items = vim.fn.getqflist()
      if #items > 0 then
        vim.cmd.cwindow()
      else
        vim.notify('No results', vim.log.levels.WARN)
      end
    end,
  })
end

autocmd('FileType', {
  group = default_group,
  pattern = { 'json', 'json5', 'jsonc' },
  desc = 'Add comma to the line end on insert under in json files',
  callback = function(args)
    vim.keymap.set('n', 'o', function()
      local line = vim.api.nvim_get_current_line()
      return line:find('[^,{[]$') and 'A,<CR>' or 'o'
    end, {
      desc = 'Add comma on insert under (json files)',
      expr = true,
      buf = args.buf,
    })
  end,
})

autocmd('FileType', {
  group = default_group,
  pattern = { 'gitcommit', 'mail', 'markdown', 'text' },
  desc = 'Enable wrap and spelling for prose files',
  callback = function()
    if vim.api.nvim_win_get_config(0).relative ~= '' then return end

    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

autocmd('FileType', {
  group = default_group,
  pattern = 'gitcommit',
  desc = 'Show staged diff in a split when editing a commit message',
  callback = function(args)
    local commit_buf = args.buf

    if vim.b[commit_buf].commit_diff_open then return end

    if vim.bo[commit_buf].buftype == 'nofile' then return end
    local commit_win = vim.fn.bufwinid(commit_buf)
    if commit_win == -1 then return end
    if vim.api.nvim_win_get_config(commit_win).relative ~= '' then return end

    vim.b[commit_buf].commit_diff_open = true

    local diff_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[diff_buf].bufhidden = 'wipe'

    vim.cmd('rightbelow vsplit')
    local diff_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(diff_win, diff_buf)
    vim.bo[diff_buf].filetype = 'diff'

    for opt, val in pairs({
      number = false,
      relativenumber = false,
      signcolumn = 'no',
      foldcolumn = '0',
      spell = false,
      wrap = false,
      list = false,
      winfixwidth = true,
    }) do
      vim.wo[diff_win][opt] = val
    end

    vim.api.nvim_set_current_win(commit_win)

    vim.system(
      { 'git', 'diff', '--cached', '--stat', '-p' },
      { text = true },
      function(obj)
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(diff_buf) then return end
          local out = obj.code == 0 and obj.stdout or obj.stderr
          local lines = vim.split(out or '', '\n', { trimempty = true })
          if #lines == 0 then lines = { '-- no staged changes --' } end
          vim.bo[diff_buf].modifiable = true
          vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, lines)
          vim.bo[diff_buf].modifiable = false
        end)
      end
    )

    local function close_diff()
      if vim.api.nvim_win_is_valid(diff_win) then
        pcall(vim.api.nvim_win_close, diff_win, true)
      end
    end

    autocmd('QuitPre', {
      buffer = commit_buf,
      once = true,
      callback = close_diff,
    })

    autocmd({ 'BufWipeout', 'BufDelete' }, {
      buffer = commit_buf,
      once = true,
      callback = close_diff,
    })
  end,
})

do
  local cursorline_group = augroup('cursorline')

  autocmd({ 'WinEnter', 'BufWinEnter', 'FocusGained', 'VimEnter' }, {
    group = cursorline_group,
    desc = 'Show cursorline only in the focused window',
    callback = function()
      if vim.bo.buftype == '' then vim.opt_local.cursorline = true end
    end,
  })

  autocmd({ 'WinLeave', 'FocusLost' }, {
    group = cursorline_group,
    desc = 'Hide cursorline in unfocused windows',
    callback = function()
      vim.opt_local.cursorline = false
    end,
  })
end

do
  local relative_number_toggle_group = augroup('relative_number_toggle')

  autocmd({ 'InsertEnter', 'WinLeave' }, {
    group = relative_number_toggle_group,
    callback = function(args)
      if vim.bo[args.buf].buftype ~= '' then return end
      if vim.wo.number then vim.wo.relativenumber = false end
    end,
  })

  autocmd({ 'InsertLeave', 'WinEnter' }, {
    group = relative_number_toggle_group,
    callback = function(args)
      if vim.bo[args.buf].buftype ~= '' then return end
      if vim.wo.number then vim.wo.relativenumber = true end
    end,
  })
end

do
  local help_group = augroup('ft_help')

  autocmd({ 'WinEnter', 'BufWinEnter' }, {
    group = help_group,
    desc = 'Open help in a right-hand vertical split',
    callback = function(args)
      if vim.bo[args.buf].buftype ~= 'help' then return end
      vim.cmd.wincmd({ args = { 'L' } })
      vim.cmd.resize({ '78', mods = { vertical = true } })
    end,
  })

  autocmd({ 'WinLeave', 'BufWinLeave' }, {
    group = help_group,
    desc = 'Open help in a right-hand vertical split',
    callback = function(args)
      if vim.bo[args.buf].buftype ~= 'help' then return end
      vim.cmd.resize({ '0', mods = { vertical = true } })
    end,
  })
end

autocmd('VimResized', {
  group = default_group,
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd.tabdo('wincmd =')
    vim.cmd.tabnext({ args = { tab } })
  end,
})

autocmd({ 'BufNewFile', 'BufReadPre' }, {
  group = augroup('secure'),
  pattern = {
    '/tmp/*',
    '*.env',
    '.env.*',
    '*.gpg',
    '*.age',
    '/dev/shm/*',
    '/private/tmp/*',
  },
  callback = function()
    vim.opt_local.backup = false
    vim.opt_local.swapfile = false
    vim.opt_local.undofile = false
    vim.opt_local.writebackup = false
  end,
})

do
  local fzf_ok, fzf = pcall(require, 'plugins.fzf')

  ---@param name string
  ---@param fallback function
  ---@return function
  local function lsp_pick(name, fallback)
    if not fzf_ok then return fallback end
    return function(...)
      return fzf.api.lsp[name](...)
    end
  end

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup(
      'devastion.lsp_attach',
      { clear = true }
    ),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end

      ---@param mode string|string[]
      ---@param lhs string
      ---@param rhs string|function
      ---@param desc string
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, {
          desc = 'LSP: ' .. desc,
          buffer = args.buf,
        })
      end

      ---@param method vim.lsp.protocol.Method.ClientToServer | vim.lsp.protocol.Method.Registration
      ---@return boolean
      local function supports(method)
        return client:supports_method(method)
      end

      if supports('textDocument/definition') then
        map(
          'n',
          'grd',
          lsp_pick('definitions', vim.lsp.buf.definition),
          'Definition'
        )
      end

      if supports('textDocument/declaration') then
        map(
          'n',
          'grD',
          lsp_pick('declarations', vim.lsp.buf.declaration),
          'Declaration'
        )
      end

      if supports('textDocument/typeDefinition') then
        map(
          'n',
          'grt',
          lsp_pick('typedefs', vim.lsp.buf.type_definition),
          'Type definition'
        )
      end

      if supports('textDocument/implementation') then
        map(
          'n',
          'gri',
          lsp_pick('implementations', vim.lsp.buf.implementation),
          'Implementation'
        )
      end

      if supports('textDocument/references') then
        map(
          'n',
          'grr',
          lsp_pick('references', vim.lsp.buf.references),
          'References'
        )
      end

      if supports('textDocument/rename') then
        map('n', 'grn', function()
          require('live-rename').rename()
        end, 'Rename')
      end

      if supports('textDocument/codeAction') then
        map(
          { 'n', 'x' },
          'gra',
          lsp_pick('code_actions', vim.lsp.buf.code_action),
          'Code action'
        )
      end

      if supports('textDocument/documentSymbol') then
        map(
          'n',
          'gO',
          lsp_pick('document_symbols', vim.lsp.buf.document_symbol),
          'Document symbols'
        )
      end

      if supports('textDocument/hover') then
        map('n', 'K', vim.lsp.buf.hover, 'Hover')
      end

      if supports('textDocument/signatureHelp') then
        map({ 'i', 'n' }, '<C-s>', vim.lsp.buf.signature_help, 'Signature help')
      end

      if supports('textDocument/codeLens') then
        map('n', 'grx', function()
          vim.lsp.codelens.run({ client_id = client.id })
        end, 'Run codelens')
        map('n', 'grX', function()
          vim.lsp.codelens.enable(true, { bufnr = args.buf })
        end, 'Refresh codelens')
      end

      if supports('callHierarchy/incomingCalls') then
        map(
          'n',
          'grI',
          lsp_pick('incoming_calls', vim.lsp.buf.incoming_calls),
          'Incoming calls'
        )
      end

      if supports('callHierarchy/outgoingCalls') then
        map(
          'n',
          'grO',
          lsp_pick('outgoing_calls', vim.lsp.buf.outgoing_calls),
          'Outgoing calls'
        )
      end
    end,
  })
end
