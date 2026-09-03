local config = {
  name = 'Scratch',
  ---@type string|fun(): string
  ft = function()
    if vim.bo.buftype == '' and vim.bo.filetype ~= '' then
      return vim.bo.filetype
    end
    return 'markdown'
  end,
  root = vim.fs.joinpath(vim.fn.stdpath('data'), 'scratch'),
  autowrite = true,
  filekey = {
    cwd = true,
    branch = true,
    count = true,
  },
  ---@type string?
  template = nil,
  width = 100,
  height = 30,
  border = 'rounded',
  ---@type table<string, string|false>
  keys = {
    open = '<leader>.',
    select = '<leader>S',
    reset = 'R',
    source = '<CR>',
  },
}

---@class ScratchFile
---@field file string
---@field name string
---@field ft string
---@field cwd? string
---@field branch? string
---@field count? integer

---@param cwd string
---@return string?
local function git_branch(cwd)
  local root = vim.fs.root(cwd, '.git')
  if not root then return nil end

  local out = vim
    .system({ 'git', '-C', root, 'branch', '--show-current' }, { text = true })
    :wait()
  if out.code ~= 0 then return nil end

  local branch = vim.trim(out.stdout or '')
  return branch ~= '' and branch or nil
end

---@param scratch ScratchFile
---@return string path
local function write_meta(scratch)
  local key = { scratch.name, scratch.ft }
  key[#key + 1] = scratch.count and tostring(scratch.count) or nil
  key[#key + 1] = scratch.cwd
  key[#key + 1] = scratch.branch

  vim.fn.mkdir(config.root, 'p')
  local hash = vim.fn.sha256(table.concat(key, '|')):sub(1, 8)
  local file = vim.fs.joinpath(config.root, ('%s.%s'):format(hash, scratch.ft))

  scratch.file = file
  vim.fn.writefile({ vim.json.encode(scratch) }, file .. '.meta')
  return file
end

---@param file string
---@return ScratchFile?
local function read_meta(file)
  local read_ok, lines = pcall(vim.fn.readfile, file .. '.meta')
  if not read_ok then return nil end

  local ok, decoded = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not ok or type(decoded) ~= 'table' then return nil end

  decoded.file = file
  return decoded
end

---@param opts? table
---@return ScratchFile
local function resolve(opts)
  opts = opts or {}

  if opts.file then
    local file = vim.fs.normalize(opts.file)
    return read_meta(file)
      or {
        file = file,
        name = vim.fs.basename(file),
        ft = vim.filetype.match({ filename = file }) or 'markdown',
      }
  end

  local ft = opts.ft or config.ft
  ft = type(ft) == 'function' and ft() or ft

  ---@type ScratchFile
  local scratch = { file = '', name = opts.name or config.name, ft = ft }
  local cwd = vim.fs.normalize(vim.uv.cwd() or vim.fn.getcwd())

  if config.filekey.count then
    local count = opts.count or vim.v.count1
    scratch.count = count > 1 and count or nil
  end
  if config.filekey.cwd then scratch.cwd = cwd end
  if config.filekey.branch then scratch.branch = git_branch(cwd) end

  write_meta(scratch)
  return scratch
end

---@return ScratchFile[]
local function list()
  local files = {}
  if vim.fn.isdirectory(config.root) == 0 then return files end

  for entry, kind in vim.fs.dir(config.root) do
    if kind == 'file' and entry:sub(-5) == '.meta' then
      local file = vim.fs.joinpath(config.root, entry:sub(1, -6))
      local stat = vim.uv.fs_stat(file)
      local scratch = stat and read_meta(file)
      if scratch then
        scratch.mtime = stat.mtime.sec
        files[#files + 1] = scratch
      end
    end
  end

  table.sort(files, function(a, b)
    return a.mtime > b.mtime
  end)
  return files
end

---Run a `lua` or `vim` scratch buffer, or the visual selection in one.
---@param buf integer
---@param range? { [1]: integer, [2]: integer } 1-indexed, inclusive
local function source(buf, range)
  local lines = range
      and vim.api.nvim_buf_get_lines(buf, range[1] - 1, range[2], false)
    or vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local chunk = table.concat(lines, '\n')

  if vim.bo[buf].filetype == 'vim' then
    local ok, err = pcall(vim.cmd, chunk)
    if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
    return
  end

  local fn, compile_error = load(chunk, '=scratch')
  if not fn then
    vim.notify(tostring(compile_error), vim.log.levels.ERROR)
    return
  end

  local ok, result = pcall(fn)
  if not ok then
    vim.notify(tostring(result), vim.log.levels.ERROR)
  elseif result ~= nil then
    vim.notify(vim.inspect(result), vim.log.levels.INFO)
  end
end

---@param buf integer
local function apply_template(buf)
  if not config.template then return end
  vim.api.nvim_buf_set_lines(
    buf,
    0,
    -1,
    false,
    vim.split(config.template, '\n')
  )
end

---@param buf integer
---@param scratch ScratchFile
local function set_keymaps(buf, scratch)
  local keys = config.keys

  if keys.reset and config.template then
    vim.keymap.set('n', keys.reset, function()
      apply_template(buf)
    end, { buffer = buf, desc = 'Reset scratch buffer' })
  end

  if keys.source and (scratch.ft == 'lua' or scratch.ft == 'vim') then
    vim.keymap.set('n', keys.source, function()
      source(buf)
    end, { buffer = buf, desc = 'Source scratch buffer' })

    vim.keymap.set('x', keys.source, function()
      vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'nx', false)
      source(buf, { vim.fn.line("'<"), vim.fn.line("'>") })
    end, { buffer = buf, desc = 'Source scratch selection' })
  end

  vim.keymap.set('n', 'q', function()
    vim.cmd.close()
  end, { buffer = buf, desc = 'Close scratch buffer' })
end

---@param value number
---@param parent integer
---@return integer
local function float_size(value, parent)
  return math.floor(value < 1 and parent * value or value)
end

---@param buf integer
---@param enter boolean
---@param opts { width: number, height: number, border: string|string[], title: string, row_offset?: integer }
---@return integer win
local function open_float(buf, enter, opts)
  local margin = 4
  local width =
    math.min(float_size(opts.width, vim.o.columns), vim.o.columns - margin)
  local height =
    math.min(float_size(opts.height, vim.o.lines), vim.o.lines - margin)

  return vim.api.nvim_open_win(buf, enter, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) + (opts.row_offset or 0),
    col = math.floor((vim.o.columns - width) / 2),
    border = opts.border,
    title = ' ' .. opts.title .. ' ',
    title_pos = 'center',
  })
end

---Open a scratch buffer, or close it when it is already on screen.
---@param opts? table
---@return integer? win
local function open(opts)
  opts = opts or {}
  local scratch = resolve(opts)

  local existed = vim.uv.fs_stat(scratch.file) ~= nil
  local buf = vim.fn.bufadd(scratch.file)

  local win = vim.fn.bufwinid(buf)
  if win ~= -1 then
    vim.api.nvim_win_close(win, false)
    return nil
  end

  if not vim.api.nvim_buf_is_loaded(buf) then vim.fn.bufload(buf) end

  vim.bo[buf].buflisted = false
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = scratch.ft

  local empty = vim.api.nvim_buf_line_count(buf) == 1
    and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ''
  if not existed and empty then apply_template(buf) end

  local title = scratch.name .. (scratch.count and (' ' .. scratch.count) or '')
  win = open_float(buf, true, {
    width = config.width,
    height = config.height,
    border = config.border,
    title = ('%s (%s)'):format(title, scratch.ft),
    row_offset = -1,
  })
  vim.wo[win].winhighlight = 'NormalFloat:Normal,FloatBorder:ScratchBorder'

  set_keymaps(buf, scratch)

  if config.autowrite then
    vim.api.nvim_create_autocmd('BufHidden', {
      group = vim.api.nvim_create_augroup(
        'devastion.scratch.' .. buf,
        { clear = true }
      ),
      buffer = buf,
      callback = function(event)
        vim.api.nvim_buf_call(event.buf, function()
          vim.cmd('silent! write')
        end)
        vim.bo[event.buf].buflisted = false
      end,
    })
  end

  return win
end

local function select()
  local files = list()
  if #files == 0 then
    vim.notify('No scratch files yet', vim.log.levels.WARN)
    return
  end

  vim.ui.select(files, {
    prompt = 'Scratch files',
    ---@param item ScratchFile
    format_item = function(item)
      local where = item.cwd and vim.fn.fnamemodify(item.cwd, ':~') or ''
      if item.branch then where = where .. ' (' .. item.branch .. ')' end
      local name = item.name .. (item.count and (' ' .. item.count) or '')
      return ('%-16s %-10s %s'):format(name, item.ft, where)
    end,
  }, function(choice)
    if choice then open({ file = choice.file }) end
  end)
end

local function set_highlight()
  vim.api.nvim_set_hl(
    0,
    'ScratchBorder',
    { link = 'FloatBorder', default = true }
  )
end
set_highlight()

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('devastion.scratch', { clear = true }),
  callback = set_highlight,
})

vim.api.nvim_create_user_command('Scratch', function(args)
  open({
    ft = args.args ~= '' and args.args or nil,
    count = args.count > 0 and args.count or nil,
  })
end, {
  count = true,
  nargs = '?',
  complete = 'filetype',
  desc = 'Toggle a scratch buffer',
})

vim.api.nvim_create_user_command(
  'ScratchSelect',
  select,
  { desc = 'Open a scratch buffer from the list' }
)

if config.keys.open then
  vim.keymap.set('n', config.keys.open, function()
    open()
  end, { desc = 'Toggle scratch buffer' })
end

if config.keys.select then
  vim.keymap.set(
    'n',
    config.keys.select,
    select,
    { desc = 'Select scratch buffer' }
  )
end
