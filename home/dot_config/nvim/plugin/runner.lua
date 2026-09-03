---@class RunnerInterpreter
---@field cmd string[]
---@field needs_file? boolean

local config = {
  ---@type table<string, RunnerInterpreter>
  interpreters = {
    bash = { cmd = { 'bash' } },
    elixir = { cmd = { 'elixir' } },
    go = { cmd = { 'go', 'run' }, needs_file = true },
    java = { cmd = { 'java' }, needs_file = true },
    javascript = { cmd = { 'node' } },
    lua = { cmd = { 'lua' } },
    python = { cmd = { 'python3' } },
    ruby = { cmd = { 'ruby' } },
    sh = { cmd = { 'sh' } },
    typescript = { cmd = { 'npx', 'tsx' } },
  },
  timeout_ms = 30000,
  max_notify_lines = 20,
  max_notify_chars = 1000,
  keys = {
    ---@type string|false
    run = false,
  },
}

---@param text string
---@param level integer
---@param title string
local function show_output(text, level, title)
  text = vim.trim(text)
  if text == '' then text = 'Executed successfully (no output)' end

  local lines = vim.split(text, '\n', { plain = true })
  if #lines <= config.max_notify_lines and #text <= config.max_notify_chars then
    vim.notify(text, level, { title = title })
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = false
  vim.bo[buf].buflisted = false

  local width = math.min(math.max(40, math.floor(vim.o.columns * 0.8)), 120)
  local height =
    math.min(math.max(5, #lines + 2), math.floor(vim.o.lines * 0.6), 32)

  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. title .. ' ',
    title_pos = 'center',
  })

  local close_opts =
    { buffer = buf, silent = true, nowait = true, desc = 'Close' }
  vim.keymap.set('n', 'q', '<cmd>close<cr>', close_opts)
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', close_opts)
end

---@param name string
---@param execute_fn function
local function run_in_process(name, execute_fn)
  local ok, result = pcall(execute_fn)
  if not ok then
    show_output(tostring(result), vim.log.levels.ERROR, name .. ' Error')
    return
  end

  local out = (type(result) == 'table' and result.output) or result
  local text = ''
  if out ~= nil then
    text = type(out) == 'string' and out or vim.inspect(out)
  end
  show_output(text, vim.log.levels.INFO, name .. ' Output')
end

---@param line1 integer
---@param line2 integer
local function run(line1, line2)
  local ft = vim.bo.filetype
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
  local code = table.concat(lines, '\n')

  if code == '' then
    vim.notify('Nothing to run', vim.log.levels.WARN)
    return
  end

  if ft == 'lua' or ft == 'vim' then
    local prompt = ('Execute %d line(s) of %s inside Neovim?'):format(
      line2 - line1 + 1,
      ft
    )
    if vim.fn.confirm(prompt, '&Yes\n&No', 2) ~= 1 then return end
  end

  if ft == 'lua' then
    local chunk, compile_err = load(code, '@[devastion.runner]')
    if not chunk then
      show_output(
        compile_err or 'Failed to load Lua code',
        vim.log.levels.ERROR,
        'Lua Compile Error'
      )
      return
    end
    run_in_process('Lua', chunk)
    return
  end

  if ft == 'vim' then
    run_in_process('Vimscript', function()
      return vim.api.nvim_exec2(code, { output = true })
    end)
    return
  end

  local interpreter = config.interpreters[ft]
  if not interpreter then
    vim.notify(
      'No interpreter configured for filetype: ' .. ft,
      vim.log.levels.WARN
    )
    return
  end

  if vim.fn.executable(interpreter.cmd[1]) ~= 1 then
    vim.notify(
      ('`%s` is not on your PATH'):format(interpreter.cmd[1]),
      vim.log.levels.ERROR
    )
    return
  end

  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local whole_file = line1 == 1 and line2 == vim.api.nvim_buf_line_count(bufnr)
  local saved = filepath ~= '' and not vim.bo[bufnr].modified

  local cmd = vim.deepcopy(interpreter.cmd)
  local stdin = nil

  if whole_file and saved then
    cmd[#cmd + 1] = filepath
  elseif interpreter.needs_file then
    -- `go run` and `java` compile a file; they cannot read source from stdin.
    vim.notify(
      ('%s can only run a saved, unmodified file in full'):format(
        interpreter.cmd[1]
      ),
      vim.log.levels.WARN
    )
    return
  else
    stdin = code
  end

  local cwd = filepath ~= '' and vim.fs.dirname(filepath) or vim.uv.cwd()

  vim.system(
    cmd,
    { stdin = stdin, cwd = cwd, text = true, timeout = config.timeout_ms },
    function(result)
      vim.schedule(function()
        if result.code == 0 then
          show_output(result.stdout or '', vim.log.levels.INFO, 'Output')
          return
        end
        local err = vim.trim(result.stderr or '')
        if err == '' then err = vim.trim(result.stdout or '') end
        if err == '' then err = 'exit ' .. result.code end
        show_output(
          err,
          vim.log.levels.ERROR,
          'Error (code ' .. result.code .. ')'
        )
      end)
    end
  )
end

vim.api.nvim_create_user_command('Runner', function(args)
  run(args.line1, args.line2)
end, { range = '%', desc = 'Run the buffer or the given line range' })

if config.keys.run then
  vim.keymap.set(
    'n',
    config.keys.run,
    '<cmd>Runner<cr>',
    { desc = 'Run buffer' }
  )
  vim.keymap.set(
    'x',
    config.keys.run,
    ':Runner<cr>',
    { desc = 'Run selection' }
  )
end
