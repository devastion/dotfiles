vim.pack.add({
  'https://github.com/nvim-mini/mini.notify',
}, { confirm = false })

local mini_notify = require('mini.notify')

---@type table<string, { timeout: integer, hl_group: string }>
local levels = {
  TRACE = { timeout = 1000, hl_group = 'DiagnosticOk' },
  DEBUG = { timeout = 1000, hl_group = 'DiagnosticHint' },
  INFO = { timeout = 3000, hl_group = 'DiagnosticInfo' },
  WARN = { timeout = 5000, hl_group = 'DiagnosticWarn' },
  ERROR = { timeout = 8000, hl_group = 'DiagnosticError' },
}

---@type table<integer, string>
local level_names = {}
for name, nr in pairs(vim.log.levels) do
  level_names[nr] = name
end

local format = function(notif)
  local title = notif.data and notif.data.title
  if title == nil then return mini_notify.default_format(notif) end
  local time = os.date('%H:%M:%S', math.floor(notif.ts_update))
  local msg = notif.msg:gsub('\n', '\n ')
  return string.format(' [%s] | %s \n %s', time, title, msg)
end

local sort = function(notif_arr)
  local result = vim.tbl_filter(function(notif)
    return notif.msg:find('Diagnosing', 1, true) == nil
  end, notif_arr)

  table.sort(result, function(a, b)
    return a.ts_update > b.ts_update
  end)

  return result
end

mini_notify.setup({
  content = { format = format, sort = sort },
  lsp_progress = { enable = true },
  window = {
    config = { border = 'single' },
    winblend = 0,
  },
})

---@param msg any
---@param level integer|string|nil
---@param opts table|nil
---@return integer|nil id
local function notify(msg, level, opts)
  opts = opts or {}
  if type(msg) ~= 'string' then msg = vim.inspect(msg) end

  local name = level_names[level]
    or (type(level) == 'string' and level:upper())
    or 'INFO'
  if name == 'OFF' then return end
  local level_data = levels[name]

  if level_data == nil then
    name, level_data = 'INFO', levels.INFO
  end

  local id = mini_notify.add(msg, name, level_data.hl_group, opts)
  if opts.manual then return id end

  vim.defer_fn(function()
    mini_notify.remove(id)
  end, opts.timeout or level_data.timeout)

  return id
end

---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
  if vim.in_fast_event() then
    return vim.schedule(function()
      notify(msg, level, opts)
    end)
  end
  return notify(msg, level, opts)
end

vim.api.nvim_create_user_command('Notifications', function()
  mini_notify.show_history()
end, { desc = 'Show notifications' })

vim.keymap.set('n', '<Esc>', function()
  for id, notif in pairs(mini_notify.get_all()) do
    local is_lsp_progress = notif.data and notif.data.source == 'lsp_progress'
    if notif.ts_remove == nil and not is_lsp_progress then
      mini_notify.remove(id)
    end
  end
  return '<Cmd>nohlsearch<CR>'
end, { expr = true, desc = 'Dismiss notifications and clear search highlight' })
