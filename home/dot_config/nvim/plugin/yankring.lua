local config = {
  max_size = 100,
  storage_file = vim.fs.joinpath(vim.fn.stdpath('data'), 'yankring.json'),
  ---@type string[]
  ignore_registers = { '_' },
  save_debounce_ms = 300,
  keys = {
    ---@type string|false
    history = '<leader>p',
  },
}

---@class YankRingEntry
---@field lines string[]
---@field regtype string
---@field timestamp integer

---@type YankRingEntry[]
local ring = {}
local loaded = false

---@type fun()|nil
local save_debounced = nil

---@generic F: function
---@param fn F
---@param ms integer
---@return F
local function debounce(fn, ms)
  local timer = assert(vim.uv.new_timer())
  return function(...)
    local argc, args = select('#', ...), { ... }
    timer:stop()
    timer:start(ms, 0, function()
      vim.schedule(function()
        fn(unpack(args, 1, argc))
      end)
    end)
  end
end

local function load_history()
  if loaded then return end
  loaded = true

  local file = io.open(config.storage_file, 'r')
  if not file then return end
  local content = file:read('*a')
  file:close()

  if not content or content == '' then return end
  local ok, decoded = pcall(vim.json.decode, content)
  if ok and type(decoded) == 'table' then ring = decoded end
end

local function save_history()
  local ok, encoded = pcall(vim.json.encode, ring)
  if not ok then return end

  local file = io.open(config.storage_file, 'w')
  if not file then return end
  file:write(encoded)
  file:close()

  pcall(vim.uv.fs_chmod, config.storage_file, tonumber('600', 8))
end

---@param lines string[]
---@param regtype string
local function add(lines, regtype)
  if type(lines) ~= 'table' or #lines == 0 then return end
  if #lines == 1 and lines[1] == '' then return end

  load_history()

  local top = ring[1]
  if top and top.regtype == regtype and vim.deep_equal(top.lines, lines) then
    return
  end

  table.insert(
    ring,
    1,
    { lines = lines, regtype = regtype, timestamp = os.time() }
  )
  while #ring > config.max_size do
    table.remove(ring)
  end

  if save_debounced then save_debounced() end
end

local function capture_yank()
  local event = vim.v.event
  if vim.tbl_contains(config.ignore_registers, event.regname) then return end
  add(event.regcontents, event.regtype)
end

---@param timestamp integer?
---@return string
local function relative_age(timestamp)
  if not timestamp then return '' end

  local seconds = os.time() - timestamp
  if seconds < 60 then return ' (just now)' end
  if seconds < 3600 then
    return (' (%dm ago)'):format(math.floor(seconds / 60))
  end
  if seconds < 86400 then
    return (' (%dh ago)'):format(math.floor(seconds / 3600))
  end
  return (' (%dd ago)'):format(math.floor(seconds / 86400))
end

---@param index integer
---@param paste_cmd 'p'|'P'
local function paste(index, paste_cmd)
  local entry = ring[index]
  if not entry then return end

  -- Pasting from history should not clobber whatever was last yanked.
  local saved_lines = vim.fn.getreg('"', 1, true)
  local saved_type = vim.fn.getregtype('"')

  vim.fn.setreg('"', entry.lines, entry.regtype)
  vim.cmd('normal! ' .. paste_cmd)
  vim.fn.setreg('"', saved_lines, saved_type)
end

---@param paste_cmd 'p' | 'P'
local function select_entry(paste_cmd)
  load_history()

  if #ring == 0 then
    vim.notify('Yank ring is empty', vim.log.levels.INFO)
    return
  end

  local items = {}
  for i, entry in ipairs(ring) do
    local preview = table.concat(entry.lines, ' '):gsub('%s+', ' ')
    if #preview > 60 then preview = preview:sub(1, 57) .. '...' end
    items[i] = string.format(
      '%2d. [%s] %s%s',
      i,
      entry.regtype,
      preview,
      relative_age(entry.timestamp)
    )
  end

  vim.ui.select(items, { prompt = 'Yank history:' }, function(_, index)
    if index then paste(index, paste_cmd) end
  end)
end

save_debounced = debounce(save_history, config.save_debounce_ms)

local group =
  vim.api.nvim_create_augroup('devastion.yankring', { clear = true })

vim.api.nvim_create_autocmd(
  'TextYankPost',
  { group = group, callback = capture_yank }
)
vim.api.nvim_create_autocmd(
  'VimLeavePre',
  { group = group, callback = save_history }
)

vim.api.nvim_create_user_command('YankHistory', function(args)
  select_entry(args.args == 'P' and 'P' or 'p')
end, {
  nargs = '?',
  complete = function()
    return { 'p', 'P' }
  end,
  desc = 'Paste from the yank history (p or P)',
})

if config.keys.history then
  vim.keymap.set(
    'n',
    config.keys.history,
    '<cmd>YankHistory<cr>',
    { desc = 'Yank history' }
  )
end
