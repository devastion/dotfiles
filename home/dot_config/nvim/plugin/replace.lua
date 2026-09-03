local config = {
  rg_args = { '--vimgrep', '--smart-case', '--fixed-strings' },
  delimiters = { '/', '#', '@', '_', '~', ';', '!', ',' },
  keys = {
    ---@type string|false
    replace = false,
  },
}

---@param find string
---@param replace string
---@return string
local function delimiter(find, replace)
  for _, d in ipairs(config.delimiters) do
    if not find:find(d, 1, true) and not replace:find(d, 1, true) then
      return d
    end
  end
  return '/'
end

---@param str string
---@param delim string
---@return string
local function escape_pattern(str, delim)
  return vim.fn.escape(str, delim .. '\\')
end

---@param str string
---@param delim string
---@return string
local function escape_replacement(str, delim)
  return vim.fn.escape(str, delim .. '\\&~')
end

---@param find string
---@param replace string
local function apply(find, replace)
  local cmd = vim.list_extend({ 'rg' }, vim.deepcopy(config.rg_args))
  vim.list_extend(cmd, { '--', find })

  vim.system(cmd, { text = true, cwd = vim.uv.cwd() }, function(result)
    vim.schedule(function()
      if result.code == 2 then
        local err = vim.trim(result.stderr or '')
        vim.notify(
          'ripgrep failed: ' .. (err ~= '' and err or ('exit ' .. result.code)),
          vim.log.levels.ERROR
        )
        return
      end

      local output = vim.trim(result.stdout or '')
      if result.code ~= 0 or output == '' then
        vim.notify('No matches found for: ' .. find, vim.log.levels.WARN)
        return
      end

      local lines = vim.split(output, '\n', { plain = true })

      local origin_win = vim.api.nvim_get_current_win()
      local origin_buf = vim.api.nvim_get_current_buf()

      vim.fn.setqflist(
        {},
        'r',
        { title = ('Replace: %s -> %s'):format(find, replace), lines = lines }
      )
      vim.cmd('copen')

      local files = {}
      for _, entry in ipairs(vim.fn.getqflist()) do
        files[entry.bufnr] = true
      end
      local file_count = vim.tbl_count(files)

      local choice = vim.fn.confirm(
        ('Replace %d match(es) in %d file(s)?'):format(#lines, file_count),
        '&Yes\n&Confirm each\n&Cancel',
        1
      )
      if choice ~= 1 and choice ~= 2 then return end

      if vim.api.nvim_win_is_valid(origin_win) then
        vim.api.nvim_set_current_win(origin_win)
      end

      local d = delimiter(find, replace)
      local flags = (choice == 2) and 'gce' or 'ge'
      local substitute = table.concat({
        '%s',
        d,
        '\\V',
        escape_pattern(find, d),
        d,
        escape_replacement(replace, d),
        d,
        flags,
      })

      local ok, err = pcall(vim.cmd, 'cfdo ' .. substitute .. ' | update')
      if not ok then
        vim.notify(
          'Replacement failed: ' .. tostring(err),
          vim.log.levels.ERROR
        )
        return
      end

      if vim.api.nvim_buf_is_valid(origin_buf) then
        pcall(vim.api.nvim_set_current_buf, origin_buf)
      end
      vim.notify(
        ('Replaced "%s" with "%s" in %d file(s)'):format(
          find,
          replace,
          file_count
        ),
        vim.log.levels.INFO
      )
    end)
  end)
end

---@param initial_find? string
local function run(initial_find)
  if vim.fn.executable('rg') ~= 1 then
    vim.notify('`rg` (ripgrep) is not on your PATH', vim.log.levels.ERROR)
    return
  end

  local function with_replacement(find)
    vim.ui.input({ prompt = 'Replace with: ' }, function(replace)
      -- An empty replacement is a deletion, which is valid; only cancelling aborts.
      if replace == nil then return end
      apply(find, replace)
    end)
  end

  if initial_find and initial_find ~= '' then
    with_replacement(initial_find)
    return
  end

  vim.ui.input({ prompt = 'Find: ' }, function(find)
    if not find or find == '' then return end
    with_replacement(find)
  end)
end

vim.api.nvim_create_user_command('Replace', function(args)
  run(args.args)
end, { nargs = '?', desc = 'Literal find and replace across the project' })

if config.keys.replace then
  vim.keymap.set('n', config.keys.replace, function()
    run()
  end, { desc = 'Find and replace in project' })
end
