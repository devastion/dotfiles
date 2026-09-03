local M = {}

local config = {
  wipe = false,
  ---@type table<string, string|false>
  keys = {
    delete = '<leader>bd',
    delete_force = '<leader>bD',
    other = '<leader>bo',
    all = false,
    invisible = false,
  },
}

---@class buffer_delete.Opts
---@field buf? integer
---@field file? string
---@field force? boolean
---@field wipe? boolean
---@field filter? fun(buf: integer): boolean

---@param buf integer
---@param force? boolean
---@return boolean proceed
local function handle_modified(buf, force)
  if force or not vim.bo[buf].modified then return true end

  local ok, choice = pcall(
    vim.fn.confirm,
    ('Save changes to %q?'):format(vim.fn.bufname(buf)),
    '&Yes\n&No\n&Cancel',
    3,
    'Question'
  )
  if not ok or choice == 0 or choice == 3 then return false end
  if choice == 2 then return true end

  local written = pcall(vim.api.nvim_buf_call, buf, vim.cmd.write)
  if not written then
    vim.notify(
      ('Could not write %s; buffer kept'):format(vim.fn.bufname(buf)),
      vim.log.levels.WARN
    )
  end
  return written
end

---@param buf integer
---@return integer
local function replacement_for(buf)
  local candidates = vim.tbl_filter(function(info)
    return info.bufnr ~= buf
  end, vim.fn.getbufinfo({ buflisted = 1 }))

  table.sort(candidates, function(a, b)
    return a.lastused > b.lastused
  end)

  return candidates[1] and candidates[1].bufnr
    or vim.api.nvim_create_buf(true, false)
end

---@param buf integer
local function detach_windows(buf)
  local wins = vim.fn.win_findbuf(buf)
  if #wins == 0 then return end

  local fallback = replacement_for(buf)

  for _, win in ipairs(wins) do
    local target = fallback

    vim.api.nvim_win_call(win, function()
      local alt = vim.fn.bufnr('#')
      if alt > 0 and alt ~= buf and vim.bo[alt].buflisted then target = alt end
    end)

    vim.api.nvim_win_set_buf(win, target)
  end
end

---@param opts buffer_delete.Opts
---@return integer?
local function resolve(opts)
  if opts.file then
    local buf = vim.fn.bufnr(opts.file)
    return buf ~= -1 and buf or nil
  end

  local buf = opts.buf or 0
  return buf == 0 and vim.api.nvim_get_current_buf() or buf
end

---@param filter fun(buf: integer): boolean
---@param opts buffer_delete.Opts
local function delete_matching(filter, opts)
  local matched = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted and filter(buf) then
      matched[#matched + 1] = buf
    end
  end

  for _, buf in ipairs(matched) do
    M.delete({ buf = buf, force = opts.force, wipe = opts.wipe })
  end

  vim.notify(string.format('Deleted %s buffers', #matched))
end

---@param opts? integer|buffer_delete.Opts Buffer number, or options.
function M.delete(opts)
  opts = type(opts) == 'number' and { buf = opts } or opts or {}
  if opts.filter then return delete_matching(opts.filter, opts) end

  local buf = resolve(opts)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    if opts.file then
      vim.notify(
        ('No matching buffer: %s'):format(opts.file),
        vim.log.levels.WARN
      )
    end
    return
  end
  if not handle_modified(buf, opts.force) then return end

  detach_windows(buf)

  if not vim.api.nvim_buf_is_valid(buf) then return end

  local wipe = opts.wipe
  if wipe == nil then wipe = config.wipe end

  local eventignore = vim.o.eventignore
  vim.o.eventignore = eventignore == '' and 'DiagnosticChanged'
    or (eventignore .. ',DiagnosticChanged')
  pcall(vim.cmd, (wipe and 'bwipeout! ' or 'bdelete! ') .. buf)
  vim.o.eventignore = eventignore
end

---@param opts? buffer_delete.Opts
function M.all(opts)
  delete_matching(function()
    return true
  end, opts or {})
end

---@param opts? buffer_delete.Opts
function M.other(opts)
  local current = vim.api.nvim_get_current_buf()
  delete_matching(function(buf)
    return buf ~= current
  end, opts or {})
end

---@param opts? buffer_delete.Opts
function M.invisible(opts)
  delete_matching(function(buf)
    return #vim.fn.win_findbuf(buf) == 0
  end, opts or {})
end

---@param arg string
---@return buffer_delete.Opts
local function parse_arg(arg)
  local number = tonumber(arg)
  if number and vim.api.nvim_buf_is_valid(number) then
    return { buf = number }
  end
  return { file = arg }
end

local command = vim.api.nvim_create_user_command

command('BufferDelete', function(args)
  local target = args.args ~= '' and parse_arg(args.args) or {}
  target.force = args.bang
  M.delete(target)
end, {
  bang = true,
  nargs = '?',
  complete = 'buffer',
  desc = 'Delete a buffer, keeping the window layout',
})

command('BufferDeleteAll', function(args)
  M.all({ force = args.bang })
end, { bang = true, desc = 'Delete every listed buffer' })

command('BufferDeleteOther', function(args)
  M.other({ force = args.bang })
end, { bang = true, desc = 'Delete every listed buffer except this one' })

command('BufferDeleteInvisible', function(args)
  M.invisible({ force = args.bang })
end, { bang = true, desc = 'Delete every listed buffer not shown in a window' })

local keys = config.keys
local function map(lhs, rhs, desc)
  if lhs then vim.keymap.set('n', lhs, rhs, { desc = desc }) end
end

map(keys.delete, M.delete, 'Delete buffer')
map(keys.delete_force, function()
  M.delete({ force = true })
end, 'Delete buffer (force)')
map(keys.other, M.other, 'Delete other buffers')
map(keys.all, M.all, 'Delete all buffers')
map(keys.invisible, M.invisible, 'Delete invisible buffers')
