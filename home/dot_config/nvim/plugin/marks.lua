local config = {
  letters = 'abcdefghijklmnopqrstuvwxyz',
  context = 5,
  layout = {
    list_width = 0.3,
    preview_width = 0.5,
    height = 0.6,
  },
  ---@type table<string, string | false>
  keys = {
    open = '<leader>m',
  },
}

local preview_ns = vim.api.nvim_create_namespace('marks.preview')

---@class MarksItem
---@field mark string
---@field lnum integer
---@field col integer
---@field text string

---@param bufnr integer
---@return MarksItem[]
local function collect_buffer_marks(bufnr)
  local items = {}

  for letter in config.letters:gmatch('.') do
    local pos = vim.api.nvim_buf_get_mark(bufnr, letter)
    if pos[1] > 0 then
      local line = vim.api.nvim_buf_get_lines(bufnr, pos[1] - 1, pos[1], false)[1]
        or ''
      items[#items + 1] =
        { mark = letter, lnum = pos[1], col = pos[2], text = vim.trim(line) }
    end
  end

  table.sort(items, function(a, b)
    if a.lnum ~= b.lnum then return a.lnum < b.lnum end
    return a.mark < b.mark
  end)

  return items
end

---@type fun()|nil
local active_close = nil

local function open_marks_menu()
  if active_close then active_close() end

  local target_bufnr = vim.api.nvim_get_current_buf()
  local items = collect_buffer_marks(target_bufnr)

  if #items == 0 then
    vim.notify('No marks set in this buffer', vim.log.levels.INFO)
    return
  end

  local origin_win = vim.api.nvim_get_current_win()

  local list_width = math.floor(vim.o.columns * config.layout.list_width)
  local preview_width = math.floor(vim.o.columns * config.layout.preview_width)
  local win_height = math.floor(vim.o.lines * config.layout.height)
  local row = math.floor((vim.o.lines - win_height) / 2)
  local col = math.floor((vim.o.columns - list_width - preview_width - 2) / 2)

  local list_lines = {}
  for i, item in ipairs(items) do
    list_lines[i] =
      string.format(' %s  %4d  %s', item.mark, item.lnum, item.text)
  end

  local list_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(list_buf, 0, -1, false, list_lines)
  vim.bo[list_buf].modifiable = false
  vim.bo[list_buf].bufhidden = 'wipe'

  local list_win = vim.api.nvim_open_win(list_buf, true, {
    relative = 'editor',
    width = list_width,
    height = win_height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' marks ',
    title_pos = 'center',
  })
  vim.wo[list_win].wrap = false
  vim.wo[list_win].cursorline = true

  local preview_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[preview_buf].bufhidden = 'wipe'
  vim.bo[preview_buf].filetype = vim.bo[target_bufnr].filetype

  local file_name = vim.fs.basename(vim.api.nvim_buf_get_name(target_bufnr))
  local preview_win = vim.api.nvim_open_win(preview_buf, false, {
    relative = 'editor',
    width = preview_width,
    height = win_height,
    row = row,
    col = col + list_width + 2,
    style = 'minimal',
    border = 'rounded',
    title = string.format(' %s ', file_name ~= '' and file_name or '[No Name]'),
    title_pos = 'center',
  })
  vim.wo[preview_win].wrap = false

  ---@return MarksItem?
  local function selected_item()
    if not vim.api.nvim_win_is_valid(list_win) then return nil end
    return items[vim.api.nvim_win_get_cursor(list_win)[1]]
  end

  local function update_preview()
    local item = selected_item()
    if not item or not vim.api.nvim_buf_is_valid(preview_buf) then return end

    local total = vim.api.nvim_buf_line_count(target_bufnr)
    local from = math.max(0, item.lnum - config.context - 1)
    local to = math.min(total, item.lnum + config.context)
    local lines = vim.api.nvim_buf_get_lines(target_bufnr, from, to, false)

    vim.bo[preview_buf].modifiable = true
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
    vim.bo[preview_buf].modifiable = false

    vim.api.nvim_buf_clear_namespace(preview_buf, preview_ns, 0, -1)
    local hl_line = item.lnum - from - 1
    vim.hl.range(
      preview_buf,
      preview_ns,
      'Visual',
      { hl_line, 0 },
      { hl_line, 0 },
      { regtype = 'V' }
    )

    if vim.api.nvim_win_is_valid(preview_win) then
      vim.api.nvim_win_set_cursor(preview_win, { item.lnum - from, 0 })
    end
  end

  local closed = false
  local group =
    vim.api.nvim_create_augroup('devastion.marks_menu', { clear = true })

  local function close()
    if closed then return end
    closed = true
    active_close = nil

    pcall(vim.api.nvim_del_augroup_by_id, group)
    if vim.api.nvim_win_is_valid(preview_win) then
      vim.api.nvim_win_close(preview_win, true)
    end
    if vim.api.nvim_win_is_valid(list_win) then
      vim.api.nvim_win_close(list_win, true)
    end
    if vim.api.nvim_win_is_valid(origin_win) then
      vim.api.nvim_set_current_win(origin_win)
    end
  end
  active_close = close

  vim.api.nvim_create_autocmd('CursorMoved', {
    group = group,
    buffer = list_buf,
    callback = update_preview,
  })

  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    pattern = tostring(list_win) .. ',' .. tostring(preview_win),
    once = true,
    callback = close,
  })

  vim.api.nvim_create_autocmd('VimResized', {
    group = group,
    once = true,
    callback = close,
  })

  vim.api.nvim_win_set_cursor(list_win, { 1, 0 })
  update_preview()

  local opts = { buffer = list_buf, nowait = true, silent = true }

  vim.keymap.set('n', '<CR>', function()
    local item = selected_item()
    close()
    if not item then return end
    if vim.api.nvim_win_is_valid(origin_win) then
      vim.api.nvim_win_set_buf(origin_win, target_bufnr)
      pcall(vim.api.nvim_win_set_cursor, origin_win, { item.lnum, item.col })
    end
  end, vim.tbl_extend('force', opts, { desc = 'Jump to mark' }))

  vim.keymap.set(
    'n',
    'q',
    close,
    vim.tbl_extend('force', opts, { desc = 'Close' })
  )
  vim.keymap.set(
    'n',
    '<Esc>',
    close,
    vim.tbl_extend('force', opts, { desc = 'Close' })
  )
end

vim.api.nvim_create_user_command(
  'Marks',
  open_marks_menu,
  { desc = 'Open the marks menu' }
)

if config.keys.open then
  vim.keymap.set(
    'n',
    config.keys.open,
    open_marks_menu,
    { desc = 'Open marks menu' }
  )
end
