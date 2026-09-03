vim.api.nvim_create_user_command('LspInfo', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = {}

  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients > 0 then
    table.insert(lines, 'Active LSP Clients:')
    for _, client in ipairs(clients) do
      table.insert(lines, '  • ' .. client.name .. ' (running)')
    end
  else
    table.insert(lines, 'No active LSP clients')
  end

  table.insert(lines, '')

  local severity = vim.diagnostic.severity
  local diagnostics = {
    Errors = #vim.diagnostic.get(bufnr, { severity = severity.ERROR }),
    Warnings = #vim.diagnostic.get(bufnr, { severity = severity.WARN }),
    Info = #vim.diagnostic.get(bufnr, { severity = severity.INFO }),
    Hints = #vim.diagnostic.get(bufnr, { severity = severity.HINT }),
  }

  table.insert(lines, 'Diagnostics:')
  for name, count in pairs(diagnostics) do
    table.insert(lines, string.format('  %-8s %d', name .. ':', count))
  end
  table.insert(lines, '')

  table.insert(lines, 'LSP Keymaps:')
  local leader_char = vim.g.mapleader or '\\'
  local buf_maps = vim.api.nvim_buf_get_keymap(bufnr, 'n')
  for _, map in ipairs(buf_maps) do
    if map.desc and map.desc:match('^LSP') then
      local lhs = map.lhs
      if lhs and lhs:sub(1, #leader_char) == leader_char then
        lhs = '<leader>' .. lhs:sub(#leader_char + 1)
      end
      table.insert(lines, string.format('  %-15s %s', lhs, map.desc))
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = 'lspinfo'

  local width = math.min(math.floor(vim.o.columns * 0.85), vim.o.columns)
  local height = math.min(math.floor(vim.o.lines * 0.85), vim.o.lines)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = 'rounded',
    style = 'minimal',
    title = ' LSP Info ',
    title_pos = 'center',
  })
  vim.wo[win].wrap = false

  local opts = { buffer = buf, silent = true }
  vim.keymap.set('n', 'q', '<cmd>close<cr>', opts)
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', opts)

  vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost' }, {
    buf = buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })
end, { desc = 'Show LSP clients, diagnostics and keymaps' })

vim.api.nvim_create_user_command('Redir', function(ctx)
  local cmd_args = ctx.args

  if ctx.bang then
    local name, rest = ctx.args:match('^(%S+)(.*)$')
    cmd_args = name and (name .. '!' .. rest) or (ctx.args .. '!')
  end

  local ok, result = pcall(vim.api.nvim_exec2, cmd_args, { output = true })
  if not ok then
    vim.notify('Redir: ' .. tostring(result), vim.log.levels.ERROR)
    return
  end

  local out = result.output or ''
  local lines = out == '' and {}
    or vim.split(out:gsub('\n$', ''), '\n', { plain = true })

  local previous = vim.fn.bufnr('Redir://output')
  if previous ~= -1 then
    pcall(vim.api.nvim_buf_delete, previous, { force = true })
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_name(buf, 'Redir://output')
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
  vim.api.nvim_open_win(buf, true, { vertical = true })

  vim.keymap.set(
    'n',
    'q',
    '<cmd>close<cr>',
    { desc = 'Close redirect buffer', buf = buf, silent = true }
  )
end, {
  nargs = '+',
  bang = true,
  complete = 'command',
  desc = 'Redirect command output to a scratch buffer',
})

do
  local cache = {}

  ---@param name string
  ---@return table|nil
  local function load_resource(name)
    if cache[name] then return cache[name] end

    local path = vim.fs.joinpath(vim.fn.stdpath('config'), 'resources', name)
    local fd = vim.uv.fs_open(path, 'r', 438)
    if not fd then
      vim.notify(name .. ' not found', vim.log.levels.ERROR)
      return
    end
    local stat = vim.uv.fs_fstat(fd)
    local contents = stat and vim.uv.fs_read(fd, stat.size, 0)
    vim.uv.fs_close(fd)

    if not contents or contents == '' then
      vim.notify(name .. ' is empty', vim.log.levels.ERROR)
      return
    end

    local ok, decoded = pcall(vim.json.decode, contents)
    if not ok or type(decoded) ~= 'table' then
      vim.notify('Failed to parse ' .. name, vim.log.levels.ERROR)
      return
    end

    cache[name] = decoded
    return decoded
  end

  ---@param char string
  local function insert_char(char)
    vim.fn.setreg('+', char)
    vim.fn.setreg('*', char)
    vim.api.nvim_put({ char }, 'c', true, true)
    vim.notify(string.format('Copied: %s ', char), vim.log.levels.INFO)
  end

  ---@class SymbolPickerOpts
  ---@field resource string
  ---@field prompt string
  ---@field format_item fun(item: any): string
  ---@field get_char fun(item: any): string

  ---@param opts SymbolPickerOpts
  local function pick_symbol(opts)
    local items = load_resource(opts.resource)
    if not items then return end

    vim.ui.select(items, {
      prompt = opts.prompt,
      format_item = opts.format_item,
    }, function(choice)
      if not choice then return end
      insert_char(opts.get_char(choice))
    end)
  end

  vim.api.nvim_create_user_command('NerdIcons', function()
    pick_symbol({
      resource = 'nerd_icons.json',
      prompt = 'Select Icon:',
      format_item = function(item)
        return string.format('%s  %-30s (%s)', item.char, item.name, item.code)
      end,
      get_char = function(item)
        return item.char
      end,
    })
  end, {})

  vim.api.nvim_create_user_command('Gitmoji', function()
    pick_symbol({
      resource = 'gitmoji.json',
      prompt = 'Select Icon:',
      format_item = function(item)
        return string.format('%s  %-30s (%s)', item.emoji, item.code, item.name)
      end,
      get_char = function(item)
        return item.emoji
      end,
    })
  end, {})

  ---@param resource string
  ---@param prompt string
  ---@return fun()
  local function pair_picker(resource, prompt)
    return function()
      pick_symbol({
        resource = resource,
        prompt = prompt,
        format_item = function(item)
          return string.format('%s  %s', item[1], item[2])
        end,
        get_char = function(item)
          return item[1]
        end,
      })
    end
  end

  vim.api.nvim_create_user_command(
    'Emoji',
    pair_picker('emoji.json', 'Select Emoji:'),
    {}
  )
  vim.api.nvim_create_user_command(
    'Unicode',
    pair_picker('unicode.json', 'Select Character:'),
    {}
  )
end
