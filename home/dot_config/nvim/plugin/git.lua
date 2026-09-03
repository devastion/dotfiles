local config = {
  max_notify_lines = 5,
  max_notify_chars = 1000,
  root_markers = {
    '.git',
    'package.json',
    'pyproject.toml',
    'Cargo.toml',
    'go.mod',
    'composer.json',
  },
  lazygit_cmd = { 'lazygit' },
  keys = {
    lazygit = '<leader>gg',
    add_buffer = '<leader>ga',
    reset_buffer = '<leader>gr',
    restore_buffer = '<leader>gR',
    add_all = '<leader>gA',
  },
}

local group = vim.api.nvim_create_augroup('devastion.git', { clear = true })

---@return string
local function get_cwd()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= '' and vim.uv.fs_stat(file) then return vim.fs.dirname(file) end
  return vim.uv.cwd() or '.'
end

---@return string?
local function get_root()
  return vim.fs.root(get_cwd(), config.root_markers)
end

---@param value number
---@param parent integer
---@return integer
local function float_size(value, parent)
  return math.floor(value < 1 and parent * value or value)
end

---@param buf integer
---@param title string
---@param size? { width: number, height: number }
---@return integer win
local function open_float(buf, title, size)
  size = size or {}

  local width =
    math.min(float_size(size.width or 0.85, vim.o.columns), vim.o.columns)
  local height =
    math.min(float_size(size.height or 0.85, vim.o.lines), vim.o.lines)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = 'rounded',
    style = 'minimal',
    title = ' ' .. title .. ' ',
    title_pos = 'center',
  })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true

  return win
end

---@param text string
---@param level integer
---@param title string
local function show_output(text, level, title)
  text = vim.trim(text)
  if text == '' then text = 'OK' end

  local lines = vim.split(text, '\n', { plain = true })
  if #lines <= config.max_notify_lines and #text <= config.max_notify_chars then
    vim.notify(text, level, { title = title })
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = 'git'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = false
  vim.bo[buf].buflisted = false

  local width = math.min(math.max(40, math.floor(vim.o.columns * 0.8)), 120)
  local height =
    math.min(math.max(5, #lines + 2), math.floor(vim.o.lines * 0.6), 32)

  open_float(buf, title, { width = width, height = height })

  local close_opts =
    { buffer = buf, silent = true, nowait = true, desc = 'Close' }
  vim.keymap.set('n', 'q', '<cmd>close<cr>', close_opts)
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', close_opts)
end

---@class GitRunOpts
---@field cwd? string
---@field silent? boolean
---@field success_message? string|fun(result: vim.SystemCompleted): string
---@field on_exit? fun(result: vim.SystemCompleted) Called on the main loop after the process exits

---@param result vim.SystemCompleted
---@return string
local function combined_output(result)
  local out = vim.trim(result.stdout or '')
  local err = vim.trim(result.stderr or '')
  if out ~= '' and err ~= '' then return out .. '\n' .. err end
  return out ~= '' and out or err
end

---@param args string[]
---@param opts? GitRunOpts
local function run(args, opts)
  opts = opts or {}
  local cmd = vim.list_extend({ 'git' }, args)

  vim.system(cmd, { text = true, cwd = opts.cwd or get_cwd() }, function(result)
    vim.schedule(function()
      if opts.on_exit then opts.on_exit(result) end
      if opts.silent then return end

      local msg = combined_output(result)
      if result.code == 0 then
        if opts.success_message then
          msg = type(opts.success_message) == 'function'
              and opts.success_message(result)
            or opts.success_message
        end
        show_output(msg, vim.log.levels.INFO, 'Git')
      else
        if msg == '' then msg = 'exit ' .. result.code end
        show_output(msg, vim.log.levels.ERROR, 'Git (' .. result.code .. ')')
      end
    end)
  end)
end

---@param line string
---@return string[]
local function split_args(line)
  local args, current, quote, escaped = {}, nil, nil, false

  for char in line:gmatch('.') do
    if escaped then
      current = (current or '') .. char
      escaped = false
    elseif char == '\\' and quote ~= "'" then
      escaped = true
    elseif quote then
      if char == quote then
        quote = nil
      else
        current = (current or '') .. char
      end
    elseif char == '"' or char == "'" then
      quote = char
      current = current or ''
    elseif char:match('%s') then
      if current then
        args[#args + 1] = current
        current = nil
      end
    else
      current = (current or '') .. char
    end
  end

  if current then args[#args + 1] = current end
  return args
end

local subcommands = {
  'add',
  'bisect',
  'blame',
  'branch',
  'checkout',
  'cherry-pick',
  'clean',
  'clone',
  'commit',
  'config',
  'diff',
  'fetch',
  'grep',
  'init',
  'log',
  'merge',
  'mv',
  'pull',
  'push',
  'rebase',
  'reflog',
  'remote',
  'reset',
  'restore',
  'revert',
  'rm',
  'shortlog',
  'show',
  'stash',
  'status',
  'submodule',
  'switch',
  'tag',
  'worktree',
}

---@param arg_lead string
---@param cmd_line string
---@return string[]
local function complete(arg_lead, cmd_line)
  if cmd_line:match('^%s*Git%s+[^%s]*$') then
    return vim.tbl_filter(function(name)
      return vim.startswith(name, arg_lead)
    end, subcommands)
  end
  return vim.fn.getcompletion(arg_lead, 'file')
end

---@param args string[]
---@param action string
local function run_on_buffer(args, action)
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    vim.notify(
      'Current buffer has no file path',
      vim.log.levels.WARN,
      { title = 'Git' }
    )
    return
  end

  local root = get_root() or get_cwd()
  local display = vim.fs.relpath(root, file) or file
  run(vim.list_extend(vim.deepcopy(args), { file }), {
    cwd = root,
    success_message = ('%s files:\n- %s'):format(action, display),
  })
end

local function open_lazygit()
  local exe = config.lazygit_cmd[1]
  if vim.fn.executable(exe) ~= 1 then
    vim.notify(
      ('`%s` is not on your PATH'):format(exe),
      vim.log.levels.ERROR,
      { title = 'Git' }
    )
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  local win = open_float(buf, 'Lazygit', {
    width = vim.o.columns,
    height = vim.o.lines,
  })

  local job = vim.fn.jobstart(config.lazygit_cmd, {
    term = true,
    cwd = get_root() or get_cwd(),
    env = { NVIM = vim.v.servername },
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    pattern = tostring(win),
    once = true,
    callback = function()
      pcall(vim.fn.jobstop, job)
    end,
  })

  vim.cmd.startinsert()
end

vim.api.nvim_create_user_command('Git', function(args)
  if vim.trim(args.args) == '' then
    vim.notify('Usage: Git <args>', vim.log.levels.WARN, { title = 'Git' })
    return
  end
  run(split_args(args.args))
end, { nargs = '*', desc = 'Run a git command', complete = complete })

vim.api.nvim_create_user_command(
  'Lazygit',
  open_lazygit,
  { desc = 'Open lazygit in a floating terminal' }
)

local function map(lhs, rhs, desc)
  if lhs then vim.keymap.set('n', lhs, rhs, { silent = true, desc = desc }) end
end

map(config.keys.lazygit, open_lazygit, 'Lazygit')
map(config.keys.add_buffer, function()
  run_on_buffer({ 'add' }, 'Added')
end, 'Git add current buffer')
map(config.keys.reset_buffer, function()
  run_on_buffer({ 'reset' }, 'Reset')
end, 'Git reset current buffer')
map(config.keys.restore_buffer, function()
  run_on_buffer({ 'restore' }, 'Restored')
end, 'Git restore current buffer')
map(config.keys.add_all, function()
  run({ 'add', '-A', '--verbose' }, {
    cwd = get_root(),
    success_message = function(result)
      local files = {}
      for line in (result.stdout or ''):gmatch('[^\n]+') do
        local file = line:match("^%a+ '(.*)'$")
        if file then files[#files + 1] = '- ' .. file end
      end
      return 'Added files:\n'
        .. (#files > 0 and table.concat(files, '\n') or '- (none)')
    end,
  })
end, 'Git add all files')
