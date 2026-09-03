vim.pack.add({
  'https://github.com/nvim-mini/mini.sessions',
}, { confirm = false })

local mini_sessions = require('mini.sessions')

mini_sessions.setup({
  directory = vim.fn.stdpath('data') .. '/sessions',
})

local function session_name()
  local cwd = vim.uv.cwd() or vim.fn.getcwd()
  if not cwd then return nil end

  return (cwd:gsub('[^%w%-_.]', '-'))
end

local function has_session(name)
  local path = vim.fs.joinpath(mini_sessions.config.directory, name)

  local stat = vim.uv.fs_stat(path)
  return stat ~= nil
end

local function is_manpager()
  return vim.bo.filetype == 'man'
end

local tracking = false

local group =
  vim.api.nvim_create_augroup('devastion.sessions', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  desc = 'Restore the session for this directory',
  nested = true,
  callback = function()
    if is_manpager() then return end
    if vim.fn.argc() ~= 0 then return end
    if #vim.api.nvim_list_uis() == 0 then return end

    local name = session_name()
    if not name then return end

    tracking = true
    if has_session(name) then mini_sessions.read(name) end
  end,
})

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = group,
  desc = 'Persist the session for this directory',
  callback = function()
    if not tracking then return end

    local name = session_name()

    if name then mini_sessions.write(name) end
  end,
})
