local config = {
  start_active = true,
  debounce = 200,
  ---@type string[]
  modes = { 'n', 'i', 'c' },
  jumplist = true,
  foldopen = true,
  cycle = false,
  notify_jump = false,
  notify_end = true,
  ---@param buf integer
  ---@return boolean
  filter = function(buf)
    return vim.g.reference_highlight ~= false
      and vim.b[buf].reference_highlight ~= false
  end,
  keys = {
    ---@type string|false
    prev = '[[',
    ---@type string|false
    next = ']]',
    ---@type string|false
    toggle = false,
  },
}

local ns = vim.api.nvim_create_namespace('nvim.lsp.references')

local active = false

---@type uv.uv_timer_t|vim.uv.Timer|nil
local timer = nil

---@return string mode
local function current_mode()
  local mode = vim.api.nvim_get_mode().mode
  if mode:sub(1, 2) == 'no' then return 'o' end

  local char = mode:sub(1, 1)
  if char == '\22' then return 'v' end
  if char == '\19' then return 's' end
  return char:lower()
end

---@param buf integer
---@param check_mode boolean
---@return boolean
local function is_enabled(buf, check_mode)
  if not active or not vim.api.nvim_buf_is_valid(buf) then return false end
  if check_mode and not vim.tbl_contains(config.modes, current_mode()) then
    return false
  end
  if not config.filter(buf) then return false end

  return #vim.lsp.get_clients({
    bufnr = buf,
    method = 'textDocument/documentHighlight',
  }) > 0
end

---@class ReferencesReference
---@field from integer[]
---@field to integer[]

---@return ReferencesReference[] references
---@return integer? current
local function get()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local references, current = {}, nil

  for _, extmark in
    ipairs(vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { details = true }))
  do
    local reference = {
      from = { extmark[2] + 1, extmark[3] },
      to = { extmark[4].end_row + 1, extmark[4].end_col },
    }
    references[#references + 1] = reference

    if
      cursor[1] >= reference.from[1]
      and cursor[1] <= reference.to[1]
      and cursor[2] >= reference.from[2]
      and cursor[2] < reference.to[2]
    then
      current = #references
    end
  end

  return references, current
end

local function update()
  if not timer then return end
  local buf = vim.api.nvim_get_current_buf()

  timer:start(config.debounce, 0, function()
    vim.schedule(function()
      if buf ~= vim.api.nvim_get_current_buf() or not is_enabled(buf, true) then
        return
      end

      vim.lsp.buf.document_highlight()
      vim.lsp.buf.clear_references()
    end)
  end)
end

---@param value boolean
---@param notify? boolean
local function set_active(value, notify)
  if active == value then return end
  active = value

  if active then
    timer = vim.uv.new_timer()

    vim.api.nvim_create_autocmd(
      { 'CursorMoved', 'CursorMovedI', 'ModeChanged' },
      {
        group = vim.api.nvim_create_augroup(
          'devastion.references',
          { clear = true }
        ),
        callback = function(event)
          if not is_enabled(event.buf, true) then
            vim.lsp.buf.clear_references()
            return
          end

          -- Moving within the highlighted word cannot change the result; leave the
          -- extmarks alone rather than round-tripping to the server for them.
          local _, current = get()
          if not current then update() end
        end,
      }
    )
  else
    pcall(vim.api.nvim_del_augroup_by_name, 'devastion.references')

    if timer then
      timer:stop()
      timer:close()
      timer = nil
    end

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end
  end

  if notify then
    vim.notify(
      'Reference highlights ' .. (active and 'enabled' or 'disabled'),
      vim.log.levels.INFO
    )
  end
end

---@param count? integer
---@param cycle? boolean
local function jump(count, cycle)
  count = count or 1
  if cycle == nil then cycle = config.cycle end

  local references, current = get()
  if not current then return end

  local index = current + count
  if cycle then index = (index - 1) % #references + 1 end

  local target = references[index]
  if not target then
    if config.notify_end then
      vim.notify('No more references', vim.log.levels.WARN)
    end
    return
  end

  if config.jumplist then vim.cmd.normal({ 'm`', bang = true }) end
  vim.api.nvim_win_set_cursor(0, target.from)
  if config.foldopen then vim.cmd.normal({ 'zv', bang = true }) end
  if config.notify_jump then
    vim.notify(
      ('Reference [%d/%d]'):format(index, #references),
      vim.log.levels.INFO
    )
  end
end

local command = vim.api.nvim_create_user_command

command('ReferencesToggle', function()
  set_active(not active, true)
end, { desc = 'Toggle LSP reference highlights' })

command('ReferencesEnable', function()
  set_active(true, true)
end, { desc = 'Enable LSP reference highlights' })

command('ReferencesDisable', function()
  set_active(false, true)
end, { desc = 'Disable LSP reference highlights' })

if config.keys.prev then
  vim.keymap.set('n', config.keys.prev, function()
    jump(-vim.v.count1)
  end, { desc = 'Prev LSP reference' })
end

if config.keys.next then
  vim.keymap.set('n', config.keys.next, function()
    jump(vim.v.count1)
  end, { desc = 'Next LSP reference' })
end

if config.keys.toggle then
  vim.keymap.set('n', config.keys.toggle, function()
    set_active(not active, true)
  end, { desc = 'Toggle LSP reference highlights' })
end

if config.start_active then set_active(true) end
