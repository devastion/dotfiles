local config = {
  width = 0.85,
  height = 0.85,
  border = 'rounded',
  winblend = 0,
  close_on_exit = true,
  keys = {
    ---@type string[] | false
    toggle = { '<C-_>', '<C-/>' },
    ---@type string | false
    normal_mode = '<C-q>',
  },
}

---@type { buf?: integer, win?: integer }
local state = {}

---@param value number
---@param parent integer
---@return integer
local function float_size(value, parent)
  return math.floor(value < 1 and parent * value or value)
end

---@return vim.api.keyset.win_config
local function win_config()
  local width = math.min(float_size(config.width, vim.o.columns), vim.o.columns)
  local height = math.min(float_size(config.height, vim.o.lines), vim.o.lines)

  return {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = config.border,
    style = 'minimal',
  }
end

---@return boolean
local function is_open()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

local function close()
  if is_open() then vim.api.nvim_win_close(state.win, true) end
  state.win = nil
end

local function open()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)
  end

  state.win = vim.api.nvim_open_win(state.buf, true, win_config())
  vim.wo[state.win].winblend = config.winblend

  if vim.bo[state.buf].buftype ~= 'terminal' then vim.cmd.terminal() end

  vim.cmd.startinsert()
end

local function toggle()
  if is_open() then
    close()
  else
    open()
  end
end

local group =
  vim.api.nvim_create_augroup('devastion.terminal', { clear = true })

vim.api.nvim_create_autocmd('TermClose', {
  group = group,
  callback = function(args)
    if not config.close_on_exit or args.buf ~= state.buf then return end
    close()
    state.buf = nil
  end,
})

vim.api.nvim_create_autocmd('VimResized', {
  group = group,
  callback = function()
    if is_open() then vim.api.nvim_win_set_config(state.win, win_config()) end
  end,
})

vim.api.nvim_create_user_command(
  'ToggleTerminal',
  toggle,
  { desc = 'Toggle the floating terminal' }
)

if config.keys.toggle then
  for _, lhs in ipairs(config.keys.toggle) do
    vim.keymap.set(
      { 'n', 't' },
      lhs,
      toggle,
      { silent = true, desc = 'Toggle floating terminal' }
    )
  end
end

if config.keys.normal_mode then
  vim.keymap.set(
    't',
    config.keys.normal_mode,
    '<C-\\><C-n>',
    { silent = true, desc = 'Escape terminal mode' }
  )
end
