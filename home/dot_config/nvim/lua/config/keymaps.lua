local map = vim.keymap.set

do
  local defaults = {
    n = { 'gO', 'gra', 'gri', 'grn', 'grr', 'grt', 'grx' },
    x = { 'gra' },
    i = { '<C-s>', '<Tab>', '<S-Tab>' },
  }

  for mode, keys in pairs(defaults) do
    for _, key in ipairs(keys) do
      pcall(vim.keymap.del, mode, key)
    end
  end
end

map('n', '<leader>qq', '<cmd>wqa<cr>', { desc = 'Save and quit all' })
map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })

do
  ---@param key 'j'|'k'
  ---@return string
  local function move_vertical(key)
    local count = vim.v.count
    if count == 0 then return 'g' .. key end
    return ("m'%d%s"):format(count, key)
  end

  map('n', 'j', function()
    return move_vertical('j')
  end, { expr = true, desc = 'Move down' })
  map('n', 'k', function()
    return move_vertical('k')
  end, { expr = true, desc = 'Move up' })

  map('x', 'g/', [[<esc>/\%V]], { desc = 'Search in visual selection' })
end

do
  map('n', '<A-j>', '<cmd>silent! m .+1<cr>==', { desc = 'Move line down' })
  map('n', '<A-k>', '<cmd>silent! m .-2<cr>==', { desc = 'Move line up' })
  map(
    'i',
    '<A-j>',
    '<esc><cmd>silent! m .+1<cr>==gi',
    { desc = 'Move line down' }
  )
  map(
    'i',
    '<A-k>',
    '<esc><cmd>silent! m .-2<cr>==gi',
    { desc = 'Move line up' }
  )
  map('x', '<A-j>', [[:<C-u>silent! '<,'>m '>+1<cr>gv=gv]], {
    desc = 'Move selection down',
  })
  map('x', '<A-k>', [[:<C-u>silent! '<,'>m '<-2<cr>gv=gv]], {
    desc = 'Move selection up',
  })
  map('x', '<', '<gv', { desc = 'Indent left and keep selection' })
  map('x', '>', '>gv', { desc = 'Indent right and keep selection' })
end

map('n', 'K', function()
  local hover =
    vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/hover' })
  if #hover > 0 then return vim.lsp.buf.hover() end

  local ok, err = pcall(vim.cmd.normal, { 'K', bang = true })
  if not ok then vim.notify(tostring(err), vim.log.levels.WARN) end
end, { desc = 'LSP hover / keywordprg' })

map(
  'n',
  'gco',
  'o<esc>Vcx<esc><Cmd>normal gcc<CR>fxa<bs>',
  { desc = 'Add comment below' }
)
map(
  'n',
  'gcO',
  'O<esc>Vcx<esc><Cmd>normal gcc<CR>fxa<bs>',
  { desc = 'Add comment above' }
)

local undo_chrs =
  { ',', '.', ';', ':', '!', '?', '=', '-', '_', '/', ' ', '<Tab>', '<CR>' }
for _, char in ipairs(undo_chrs) do
  map('i', char, '<C-g>u' .. char, { desc = 'Undo breakpoint on ' .. char })
end

map({ 'x', 'o' }, "a'", "2i'", { desc = "Around single quotes ''" })
map({ 'x', 'o' }, 'a"', '2i"', { desc = 'Around double quotes ""' })
map({ 'x', 'o' }, 'a`', '2i`', { desc = 'Around backtick quotes ``' })

do
  for key, spec in pairs({
    ['d'] = { 'tabclose', 'Close tab' },
    ['o'] = { 'tabonly', 'Close other tabs' },
    ['n'] = { 'tabnew', 'New tab' },
    ['0'] = { 'tabfirst', 'First tab' },
    ['$'] = { 'tablast', 'Last tab' },
    ['e'] = { 'tabe .', 'Open directory in new tab' },
    ['<Tab>'] = { 'tabprevious', 'Previous tab' },
  }) do
    map('n', '<leader><Tab>' .. key, ('<Cmd>%s<CR>'):format(spec[1]), {
      desc = spec[2],
    })
  end
end

map('n', '<leader>`', function()
  if vim.fn.bufnr('#') == -1 then
    return vim.notify('No alternate buffer', vim.log.levels.WARN)
  end
  vim.cmd.buffer('#')
end, { desc = 'Switch to alternate buffer' })

do
  map('n', '<leader>bn', '<cmd>enew<cr>', { desc = 'New buffer' })

  map('n', 'gsf', [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], {
    desc = 'Replace word under cursor (file)',
  })
  map('n', 'gsl', [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], {
    desc = 'Replace word under cursor (line)',
  })

  ---@param prefill boolean
  local function visual_substitute(prefill)
    local region = vim.fn.getregion(
      vim.fn.getpos('v'),
      vim.fn.getpos('.'),
      { type = vim.fn.mode() }
    )

    local search, replace = {}, {}
    for i, line in ipairs(region) do
      search[i] = vim.fn.escape(line, '/\\')
      replace[i] = vim.fn.escape(line, '/\\&~')
    end

    local keys = ('<Esc>:%%s/\\V%s/'):format(table.concat(search, '\\n'))
    if prefill then
      keys = keys .. table.concat(replace, '\\r') .. '/gI<Left><Left><Left>'
    end

    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(keys, true, false, true),
      'n',
      false
    )
  end

  map('x', 'gsf', function()
    visual_substitute(false)
  end, { desc = 'Replace selection (file)' })
  map('x', 'gsR', function()
    visual_substitute(true)
  end, { desc = 'Replace selection, prefilled (file)' })
end

do
  map('n', '<leader>cd', vim.diagnostic.open_float, {
    desc = 'Show diagnostic float',
  })
  map('n', '<leader>cc', function()
    vim.diagnostic.reset(nil, 0)
  end, { desc = 'Reset diagnostics' })
  map('n', '<leader>cq', vim.diagnostic.setqflist, {
    desc = 'Diagnostics to quickfix',
  })
end

do
  ---@param after boolean
  local function put_linewise(after)
    local lines = vim.fn.getreg(vim.v.register, 1, true) --[[@as string[] ]]
    while #lines > 0 and lines[#lines] == '' do
      table.remove(lines)
    end
    if #lines == 0 then return end

    vim.api.nvim_put(lines, 'l', after, true)
    vim.cmd("silent '[,']normal! ==")
  end

  map('n', '=p', function()
    put_linewise(true)
  end, { desc = 'Put linewise after cursor' })
  map('n', '=P', function()
    put_linewise(false)
  end, { desc = 'Put linewise before cursor' })

  ---@return string
  local function default_register()
    local clipboard = vim.o.clipboard
    if clipboard:find('unnamedplus', 1, true) then return '+' end
    if clipboard:find('unnamed', 1, true) then return '*' end
    return '"'
  end

  ---@param keys string
  ---@return string
  local function blackhole(keys)
    return vim.v.register == default_register() and '"_' .. keys or keys
  end

  map('n', 'dd', function()
    local blank = vim.api.nvim_get_current_line():match('^%s*$')
    return blank and blackhole('dd') or 'dd'
  end, { expr = true, desc = 'Smart delete line (skip yank for empty line)' })

  map(
    'x',
    'd',
    function()
      local first, last = vim.fn.line('v'), vim.fn.line('.')
      if first > last then
        first, last = last, first
      end
      for _, line in
        ipairs(vim.api.nvim_buf_get_lines(0, first - 1, last, false))
      do
        if not line:match('^%s*$') then return 'd' end
      end
      return blackhole('d')
    end,
    { expr = true, desc = 'Smart delete selection (skip yank for whitespace)' }
  )

  map({ 'n', 'x' }, 'x', function()
    return blackhole('x')
  end, { expr = true, desc = 'Delete char without yanking' })
end

do
  local textobjects = {
    ['.'] = 'dot',
    [':'] = 'colon',
    [','] = 'comma',
    [';'] = 'semicolon',
    ['<bar>'] = 'pipe',
    ['/'] = 'slash',
    ['<bslash>'] = 'backslash',
    ['*'] = 'asterisk',
    ['+'] = 'plus',
    ['-'] = 'hyphen',
    ['#'] = 'hash',
  }

  for char, description in pairs(textobjects) do
    map('x', 'i' .. char, (':<C-u>normal! T%svt%s<CR>'):format(char, char), {
      desc = 'Inside ' .. description,
    })
    map('o', 'i' .. char, (':normal vi%s<CR>'):format(char), {
      desc = 'Inside ' .. description,
    })
    map('x', 'a' .. char, (':<C-u>normal! F%svf%s<CR>'):format(char, char), {
      desc = 'Around ' .. description,
    })
    map('o', 'a' .. char, (':normal va%s<CR>'):format(char), {
      desc = 'Around ' .. description,
    })
  end

  map({ 'x', 'o' }, 'ae', function()
    vim.cmd.normal({ "m'", bang = true })
    vim.cmd.normal({ 'ggVG', bang = true, mods = { keepjumps = true } })
  end, { desc = 'Entire buffer' })

  map('o', 'i_', '<Cmd>normal! ^vg_<CR>', { desc = 'Inside line' })
  map('x', 'i_', '<Cmd>normal! ^og_<CR>', { desc = 'Inside line' })
  map('o', 'a_', '<Cmd>normal! 0v$<CR>', { desc = 'Around line' })
  map('x', 'a_', '<Cmd>normal! 0o$<CR>', { desc = 'Around line' })
  map('o', 'p', 'i(', { desc = 'Inside parentheses ()' })
end
