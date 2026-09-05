local config = {
  storage_file = vim.fs.joinpath(vim.fn.stdpath('data'), 'anchors.json'),

  ---@type { key: string, name: string }[]
  menus = {
    { key = 'f', name = 'files' },
    { key = 't', name = 'tests' },
  },

  width = 60,

  height = 9,

  ---@type table<string,string|false>
  keys = {
    open = '<C-e>',
    add = '<localleader>a',
    add_prefix = '<leader>h',
  },

  ---@type table<string,string|string[]>
  menu_keys = {
    next_menu = '<Tab>',
    prev_menu = '<S-Tab>',
    select = '<CR>',
    close = { 'q', '<Esc>' },
  },
}

---@type table<string, table<string, string[]>>
local state = {}
local loaded = false

---@type string?
local written = nil

local current = 1
local cursor_positions = {}

---@param value string|string[]|false|nil
---@return string[]
local function keylist(value)
  if not value then return {} end
  return type(value) == 'table' and value or { value }
end

---@return string
local function cwd()
  return vim.uv.cwd() or vim.fn.getcwd()
end

---@param path string
---@return string?
local function read_file(path)
  local fd = vim.uv.fs_open(path, 'r', 438)
  if not fd then return nil end

  local content
  local stat = vim.uv.fs_fstat(fd)
  if stat and stat.size > 0 then
    local chunks, offset = {}, 0
    while offset < stat.size do
      local ok, chunk = pcall(vim.uv.fs_read, fd, stat.size - offset, offset)
      if not ok or not chunk or chunk == '' then break end
      chunks[#chunks + 1] = chunk
      offset = offset + #chunk
    end
    content = table.concat(chunks)
  end

  vim.uv.fs_close(fd)
  return content
end

---@param path string
---@param data string
---@return boolean
local function write_file(path, data)
  local tmp = path .. '.tmp'

  local fd = vim.uv.fs_open(tmp, 'w', 438)
  if not fd then return false end

  local ok = pcall(vim.uv.fs_write, fd, data, 0)
  pcall(vim.uv.fs_fsync, fd)
  vim.uv.fs_close(fd)

  if not ok then
    vim.uv.fs_unlink(tmp)
    return false
  end

  return vim.uv.fs_rename(tmp, path) ~= nil
end

---@return boolean ok, string encoded
local function encode_state()
  local pruned = {}

  for project, menus in pairs(state) do
    local kept
    for name, list in pairs(menus) do
      if type(list) == 'table' and #list > 0 then
        kept = kept or {}
        kept[name] = list
      end
    end
    if kept then pruned[project] = kept end
  end

  if next(pruned) == nil then return true, '{}' end

  return pcall(vim.json.encode, pruned)
end

local function load_state()
  if loaded then return end
  loaded = true

  local content = read_file(config.storage_file)
  if content and content ~= '' then
    local ok, decoded = pcall(vim.json.decode, content)
    if ok and type(decoded) == 'table' then state = decoded end
  end

  local ok, encoded = encode_state()
  written = ok and encoded or nil
end

local function save_state()
  local ok, encoded = encode_state()
  if not ok or encoded == written then return end

  if write_file(config.storage_file, encoded) then
    written = encoded
  else
    vim.notify(
      'Anchor: cannot write ' .. config.storage_file,
      vim.log.levels.ERROR
    )
  end
end

---@param menu string
---@return string[]
local function get_list(menu)
  load_state()
  local project = state[cwd()]
  return (project and project[menu]) or {}
end

---@param menu string
---@param list string[]
local function set_list(menu, list)
  load_state()

  local key = cwd()
  local project = state[key]
  if not project then
    if #list == 0 then return end
    project = {}
    state[key] = project
  end

  project[menu] = list
  save_state()
end

---@param path string
---@return boolean
local function file_exists(path)
  return vim.uv.fs_stat(vim.fs.abspath(path)) ~= nil
end

---@param menu string
local function prune_menu(menu)
  local list = get_list(menu)

  local kept = {}
  for _, path in ipairs(list) do
    if file_exists(path) then kept[#kept + 1] = path end
  end

  if #kept ~= #list then set_list(menu, kept) end
end

local function prune_all()
  for _, menu in ipairs(config.menus) do
    prune_menu(menu.name)
  end
end

---@return string
local function current_menu()
  return config.menus[current].name
end

local highlight_ns = vim.api.nvim_create_namespace('anchor_current_file')

vim.api.nvim_set_hl(0, 'AnchorCurrentFile', { link = 'Title', default = true })

---@param line string
---@return string
local function parse_line(line)
  return vim.trim(line:match('^%s*%d+%s+(.*)$') or line)
end

---@param menu string
local function add(menu)
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    vim.notify('Current buffer has no file path', vim.log.levels.WARN)
    return
  end

  local rel = vim.fs.relpath(cwd(), path) or path
  local list = get_list(menu)

  if vim.tbl_contains(list, rel) then
    vim.notify(('%s is already in %s'):format(rel, menu), vim.log.levels.INFO)
    return
  end

  list[#list + 1] = rel
  set_list(menu, list)
  vim.notify(('Added %s to %s'):format(rel, menu), vim.log.levels.INFO)
end

local function open()
  load_state()
  prune_all()

  local origin_path = vim.api.nvim_buf_get_name(0)
  local origin_rel = origin_path ~= ''
      and (vim.fs.relpath(cwd(), origin_path) or origin_path)
    or nil

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = true

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = config.width,
    height = config.height,
    row = math.floor((vim.o.lines - config.height) / 2),
    col = math.floor((vim.o.columns - config.width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' anchors ',
    title_pos = 'center',
  })

  local function render_buffer()
    local lines = {}
    local current_line
    for i, path in ipairs(get_list(current_menu())) do
      lines[i] = string.format('%d  %s', i, path)
      if origin_rel and path == origin_rel then current_line = i end
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.api.nvim_buf_clear_namespace(buf, highlight_ns, 0, -1)
    if current_line then
      vim.hl.range(
        buf,
        highlight_ns,
        'AnchorCurrentFile',
        { current_line - 1, 0 },
        { current_line - 1, 0 },
        { regtype = 'V' }
      )
    end
  end

  local function render_footer()
    if not vim.api.nvim_win_is_valid(win) then return end

    local footer = {}
    for i, menu in ipairs(config.menus) do
      footer[#footer + 1] = {
        (' %s [%s] '):format(menu.name, menu.key),
        i == current and 'PmenuSel' or 'Comment',
      }
    end
    vim.api.nvim_win_set_config(win, { footer = footer, footer_pos = 'center' })
  end

  local function remember_cursor()
    if vim.api.nvim_win_is_valid(win) then
      cursor_positions[current_menu()] = vim.api.nvim_win_get_cursor(win)[1]
    end
  end

  local function restore_cursor()
    if not vim.api.nvim_win_is_valid(win) then return end

    local list = get_list(current_menu())
    local row
    if origin_rel then
      for i, path in ipairs(list) do
        if path == origin_rel then
          row = i
          break
        end
      end
    end

    row = row
      or math.min(cursor_positions[current_menu()] or 1, math.max(#list, 1))
    vim.api.nvim_win_set_cursor(win, { row, 0 })
  end

  ---@param row integer 1-indexed
  ---@return string
  local function path_at(row)
    if not vim.api.nvim_buf_is_valid(buf) then return '' end
    local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
    return line and parse_line(line) or ''
  end

  local function sync()
    if not vim.api.nvim_buf_is_valid(buf) then return end

    local cleaned = {}
    for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
      local path = parse_line(line)
      if path ~= '' then cleaned[#cleaned + 1] = path end
    end
    set_list(current_menu(), cleaned)
  end

  local closed = false
  local function close()
    if closed then return end
    closed = true
    remember_cursor()
    sync()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end

  ---@param index integer Wraps around
  local function show_menu(index)
    remember_cursor()
    sync()
    current = ((index - 1) % #config.menus) + 1
    render_buffer()
    render_footer()
    restore_cursor()
  end

  ---@param path string
  local function edit(path)
    close()
    vim.cmd.edit(vim.fn.fnameescape(path))
  end

  render_buffer()
  render_footer()
  restore_cursor()

  local function map(lhs, rhs, desc)
    vim.keymap.set(
      'n',
      lhs,
      rhs,
      { buffer = buf, nowait = true, silent = true, desc = desc }
    )
  end

  for _, lhs in ipairs(keylist(config.menu_keys.next_menu)) do
    map(lhs, function()
      show_menu(current + 1)
    end, 'Next list')
  end

  for _, lhs in ipairs(keylist(config.menu_keys.prev_menu)) do
    map(lhs, function()
      show_menu(current - 1)
    end, 'Previous list')
  end

  for i, menu in ipairs(config.menus) do
    map(menu.key, function()
      show_menu(i)
    end, 'Open ' .. menu.name .. ' list')
  end

  for _, lhs in ipairs(keylist(config.menu_keys.select)) do
    map(lhs, function()
      if not vim.api.nvim_win_is_valid(win) then return end
      local path = path_at(vim.api.nvim_win_get_cursor(win)[1])
      if path ~= '' then
        edit(path)
      else
        close()
      end
    end, 'Open entry')
  end

  for i = 1, math.min(9, config.height) do
    map(tostring(i), function()
      local path = path_at(i)
      if path ~= '' then edit(path) end
    end, 'Open entry ' .. i)
  end

  for _, lhs in ipairs(keylist(config.menu_keys.close)) do
    map(lhs, close, 'Close')
  end

  vim.api.nvim_create_autocmd(
    'BufLeave',
    { buffer = buf, once = true, callback = close }
  )
end

---@return string[]
local function menu_names()
  return vim.tbl_map(function(menu)
    return menu.name
  end, config.menus)
end

vim.api.nvim_create_autocmd('BufDelete', {
  group = vim.api.nvim_create_augroup('anchor_prune_menu', { clear = true }),
  callback = function(args)
    local path = vim.api.nvim_buf_get_name(args.buf)
    if path == '' or vim.uv.fs_stat(path) then return end
    prune_all()
  end,
})

vim.api.nvim_create_user_command(
  'Anchor',
  open,
  { desc = 'Open the anchor menu' }
)

vim.api.nvim_create_user_command('AnchorAdd', function(args)
  local names = menu_names()
  local menu = args.args ~= '' and args.args or names[1]
  if not vim.tbl_contains(names, menu) then
    vim.notify(
      ('Unknown list "%s". Available: %s'):format(
        menu,
        table.concat(names, ', ')
      ),
      vim.log.levels.ERROR
    )
    return
  end
  add(menu)
end, {
  nargs = '?',
  complete = menu_names,
  desc = 'Add the current file to an anchor list',
})

if config.keys.open then
  vim.keymap.set('n', config.keys.open, open, { desc = 'Anchor: open menu' })
end

if config.keys.add then
  vim.keymap.set('n', config.keys.add, function()
    add('files')
  end, { desc = 'Anchor: add file' })
end

if config.keys.add_prefix then
  for _, menu in ipairs(config.menus) do
    vim.keymap.set('n', config.keys.add_prefix .. menu.key, function()
      add(menu.name)
    end, { desc = 'Anchor: add to ' .. menu.name })
  end
end
