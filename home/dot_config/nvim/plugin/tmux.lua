local pane = vim.env.TMUX_PANE

if vim.env.TMUX == nil or pane == nil then return end

local config = {
  suppress_prefix = true,
  exit_timeout_ms = 1000,
  keys = {
    left = '<C-h>',
    down = '<C-j>',
    up = '<C-k>',
    right = '<C-l>',
  },
}

local NO_PREFIX = 'None'

---@param cmds string[][]
---@return vim.SystemObj
local function tmux(cmds)
  local argv = { 'tmux' }
  for i, cmd in ipairs(cmds) do
    if i > 1 then argv[#argv + 1] = ';' end
    vim.list_extend(argv, cmd)
  end
  return vim.system(argv)
end

local SUPPRESS = { 'set-option', '-t', pane, 'prefix', NO_PREFIX }

---@type string[]
local restore = { 'set-option', '-ut', pane, 'prefix' }

---@param on boolean
---@return string[]
local function is_vim(on)
  return { 'set-option', '-pt', pane, '@is-vim', on and '1' or '0' }
end

---@type boolean
local suppressed = false

---@param on boolean
local function set_suppressed(on)
  if not config.suppress_prefix or on == suppressed then return end
  suppressed = on
  tmux({ on and SUPPRESS or restore })
end

local function detach()
  local cmds = { is_vim(false) }
  if suppressed then cmds[#cmds + 1] = restore end
  tmux(cmds):wait(config.exit_timeout_ms)
  suppressed = false
end

---@param mode string
---@return boolean
local function is_blocking(mode)
  return mode:find('^[iRc]') ~= nil
end

local PANE_FLAGS = { h = '-L', j = '-D', k = '-U', l = '-R' }

---@param direction 'h'|'j'|'k'|'l'
local function navigate(direction)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(direction)

  if win == vim.api.nvim_get_current_win() then
    tmux({ { 'select-pane', '-t', pane, PANE_FLAGS[direction] } })
  end
end

local group = vim.api.nvim_create_augroup('devastion.tmux', { clear = true })

tmux({ is_vim(true) })

local DIRECTIONS = { h = 'left', j = 'down', k = 'up', l = 'right' }
for direction, name in pairs(DIRECTIONS) do
  local lhs = config.keys[name]
  if lhs then
    vim.keymap.set('n', lhs, function()
      navigate(direction)
    end, {
      silent = true,
      desc = ('Navigate %s (tmux aware)'):format(name),
    })
    vim.keymap.set('t', lhs, '<C-\\><C-n>' .. lhs, {
      silent = true,
      desc = ('Navigate %s (tmux aware)'):format(name),
    })
  end
end

vim.api.nvim_create_autocmd({ 'VimLeavePre', 'VimSuspend' }, {
  group = group,
  callback = detach,
})

vim.api.nvim_create_autocmd('VimResume', {
  group = group,
  callback = function()
    tmux({ is_vim(true) })
    set_suppressed(is_blocking(vim.fn.mode()))
  end,
})

if not config.suppress_prefix then return end

vim.api.nvim_create_autocmd('ModeChanged', {
  group = group,
  callback = function(args)
    local new_mode = vim.split(args.match, ':')[2]
    set_suppressed(is_blocking(new_mode))
  end,
})

vim.system(
  { 'tmux', 'show-option', '-qv', '-t', pane, 'prefix' },
  { text = true },
  function(result)
    if result.code ~= 0 then return end
    local prefix = (result.stdout or ''):match('%S+')
    if prefix == nil or prefix == NO_PREFIX then return end
    restore = { 'set-option', '-t', pane, 'prefix', prefix }
  end
)
