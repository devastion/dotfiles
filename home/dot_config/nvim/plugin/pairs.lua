local config = {
  brackets = true,
  quotes = true,
  backspace = true,
  enter = true,
  tags = true,
  visual_wrap = false,
  ---@type table<string, string | false>
  keys = {
    toggle = false,
  },
  ---@type table<string, string>
  bracket_pairs = { ['('] = ')', ['['] = ']', ['{'] = '}' },
  ---@type string[]
  quote_chars = { '"', "'", '`' },
  ---@type table<string, boolean>
  self_closing_tags = {
    area = true,
    base = true,
    br = true,
    col = true,
    embed = true,
    hr = true,
    img = true,
    input = true,
    keygen = true,
    link = true,
    meta = true,
    param = true,
    source = true,
    track = true,
    wbr = true,
  },
  ---@type table<string, boolean>
  tag_filetypes = {
    astro = true,
    heex = true,
    html = true,
    javascriptreact = true,
    jinja = true,
    markdown = true,
    php = true,
    svelte = true,
    typescriptreact = true,
    vue = true,
    xhtml = true,
    xml = true,
  },
}

-- Runtime kill switch, e.g. for pasting text without auto-pairing interference.
local enabled = true

local function toggle()
  enabled = not enabled
  vim.notify(
    'Pairs: ' .. (enabled and 'enabled' or 'disabled'),
    vim.log.levels.INFO
  )
end

vim.api.nvim_create_user_command(
  'PairsToggle',
  toggle,
  { desc = 'Toggle auto-pairing on/off' }
)

---@return string before, string next_char
local function cursor_context()
  local col = vim.fn.col('.')
  local line = vim.fn.getline('.')
  return line:sub(1, col - 1), line:sub(col, col)
end

---@return boolean
local function pum_visible()
  return vim.fn.pumvisible() == 1
end

local function close_tag()
  if not enabled or not config.tag_filetypes[vim.bo.filetype] then
    return '>'
  end

  local before = cursor_context()
  local tag = before:match('<([a-zA-Z][%w%-_:]*)[^>]*$')
  if
    tag
    and not config.self_closing_tags[tag:lower()]
    and not before:find('/$')
  then
    local close = '</' .. tag .. '>'
    return '>' .. close .. string.rep('<Left>', #close)
  end
  return '>'
end

---@param char string
local function close_pair(char)
  if not enabled then return char end
  local _, next_char = cursor_context()
  return next_char == char and '<Right>' or char
end

---@param char string
local function close_quote(char)
  if not enabled then return char end
  local before, next_char = cursor_context()
  if next_char == char then return '<Right>' end
  if char == "'" and before:sub(-1):match('[%w]') then return "'" end
  return char .. char .. '<Left>'
end

local function backspace_pair()
  if not enabled or pum_visible() then return '<BS>' end

  local before, next_char = cursor_context()
  local prev_char = before:sub(-1)
  if prev_char == '' then return '<BS>' end

  local closing = config.bracket_pairs[prev_char]
  if closing == nil and vim.tbl_contains(config.quote_chars, prev_char) then
    closing = prev_char
  end

  return closing == next_char and '<BS><Delete>' or '<BS>'
end

local function expand_enter()
  if not enabled or pum_visible() then return '<C-g>u<CR>' end

  local before, next_char = cursor_context()
  local prev_char = before:sub(-1)
  if prev_char == '' then return '<C-g>u<CR>' end

  local between_brackets = config.bracket_pairs[prev_char] == next_char
  local between_tags = prev_char == '>' and next_char == '<'

  if between_brackets or between_tags then return '<C-g>u<CR><C-o>O' end

  return '<C-g>u<CR>'
end

local function imap(lhs, rhs, desc)
  vim.keymap.set('i', lhs, rhs, { expr = true, silent = true, desc = desc })
end

local function xmap(lhs, rhs, desc)
  vim.keymap.set('x', lhs, rhs, { expr = true, silent = true, desc = desc })
end

---@param open string
---@param close string
---@param pressed string
local function wrap_selection(open, close, pressed)
  if not enabled or vim.fn.mode() ~= 'v' then return pressed end
  return 'c' .. open .. '<C-r>"' .. close .. '<Esc>'
end

if config.tags then imap('>', close_tag, 'Autoclose HTML tag') end

if config.brackets then
  for open_char, close_char in pairs(config.bracket_pairs) do
    imap(open_char, function()
      if not enabled then return open_char end
      return open_char .. close_char .. '<Left>'
    end, 'Autoclose ' .. open_char)
    imap(close_char, function()
      return close_pair(close_char)
    end, 'Autopair skip ' .. close_char)

    if config.visual_wrap then
      local wrap_desc = 'Wrap selection in ' .. open_char .. close_char
      xmap(open_char, function()
        return wrap_selection(open_char, close_char, open_char)
      end, wrap_desc)
      xmap(close_char, function()
        return wrap_selection(open_char, close_char, close_char)
      end, wrap_desc)
    end
  end
end

if config.quotes then
  for _, char in ipairs(config.quote_chars) do
    imap(char, function()
      return close_quote(char)
    end, 'Autopair ' .. char)
    if config.visual_wrap then
      xmap(char, function()
        return wrap_selection(char, char, char)
      end, 'Wrap selection in ' .. char)
    end
  end
end

if config.backspace then imap('<BS>', backspace_pair, 'Autopair backspace') end
if config.enter then imap('<CR>', expand_enter, 'Autopair expand enter') end

if config.keys.toggle then
  vim.keymap.set(
    'n',
    config.keys.toggle,
    toggle,
    { desc = 'Toggle auto-pairing' }
  )
end
