local config = {
  lsp_timeout_ms = 1000,
  file_mode = '644',
  keys = {
    create = '<leader>Fn',
    create_in_folder = '<leader>FN',
    duplicate = '<leader>Fd',
    move_selection = '<leader>Fs',
    rename = '<leader>Fr',
    move_to_folder = '<leader>Fm',
    move_and_rename = '<leader>FM',
    chmod_x = '<leader>Fx',
    trash = '<leader>FD',
    reveal = '<leader>Fe',
  },
}

local function notify_info(msg)
  vim.notify(msg, vim.log.levels.INFO)
end

local function notify_warn(msg)
  vim.notify(msg, vim.log.levels.WARN)
end

local function notify_error(msg)
  vim.notify(msg, vim.log.levels.ERROR)
end

---@return integer? bufnr, string? path
local function current_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then
    notify_warn('Current buffer has no file path')
    return nil, nil
  end
  return bufnr, path
end

---@param dir string
---@return boolean ok
local function ensure_dir(dir)
  local ok, result = pcall(vim.fn.mkdir, dir, 'p')
  if not ok or result == 0 then
    notify_error('Failed to create ' .. dir .. ': ' .. tostring(result))
    return false
  end
  return true
end

---@param dest string
---@return boolean proceed
local function confirm_overwrite(dest)
  if not vim.uv.fs_stat(dest) then return true end
  return vim.fn.confirm(dest .. ' already exists. Overwrite?', '&Yes\n&No', 2)
    == 1
end

---@param err string|nil
---@return boolean
local function is_eexist(err)
  return err ~= nil and tostring(err):match('^EEXIST') ~= nil
end

---@param path string
---@param content string
---@param callback fun(err?: string) Called on the main loop
local function write_new_file(path, content, callback)
  local function done(err)
    vim.schedule(function()
      callback(err)
    end)
  end

  vim.uv.fs_open(
    path,
    'wx',
    tonumber(config.file_mode, 8),
    function(open_err, fd)
      if open_err or not fd then
        return done(open_err or ('could not create ' .. path))
      end

      local function write_at(offset)
        if offset >= #content then
          vim.uv.fs_close(fd)
          return done()
        end
        vim.uv.fs_write(
          fd,
          content:sub(offset + 1),
          offset,
          function(write_err, written)
            if write_err or not written or written == 0 then
              vim.uv.fs_close(fd)
              return done(write_err or 'write made no progress')
            end
            write_at(offset + written)
          end
        )
      end

      write_at(0)
    end
  )
end

---@param path string
---@param callback fun(err?: string) Called on the main loop
local function create_empty_file(path, callback)
  vim.uv.fs_open(path, 'wx', tonumber(config.file_mode, 8), function(err, fd)
    if fd then vim.uv.fs_close(fd) end
    vim.schedule(function()
      callback(err)
    end)
  end)
end

---Shared completion handler for the two "create a file" commands.
---@param dest string
---@param label string
---@param err string|nil
local function on_created(dest, label, err)
  if is_eexist(err) then
    notify_warn(label .. ' already exists; opening it')
    vim.cmd.edit(vim.fn.fnameescape(dest))
    return
  end
  if err then
    notify_error('Could not create ' .. dest .. ': ' .. tostring(err))
    return
  end
  notify_info('Created: ' .. label)
  vim.cmd.edit(vim.fn.fnameescape(dest))
end

---@param from string
---@param to string
---@return lsp.RenameFilesParams
local function rename_files_params(from, to)
  return {
    files = {
      {
        oldUri = vim.uri_from_fname(from),
        newUri = vim.uri_from_fname(to),
      },
    },
  }
end

---Ask LSP clients to update imports/references before the file moves.
---@param from string
---@param to string
local function lsp_will_rename_files(from, to)
  local params = rename_files_params(from, to)
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client:supports_method('workspace/willRenameFiles') then
      local res = client:request_sync(
        'workspace/willRenameFiles',
        params,
        config.lsp_timeout_ms,
        0
      )
      if res and res.result then
        vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding)
      end
    end
  end
end

---@param from string
---@param to string
local function lsp_did_rename_files(from, to)
  local params = rename_files_params(from, to)
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client:supports_method('workspace/didRenameFiles') then
      client:notify('workspace/didRenameFiles', params)
    end
  end
end

---@param bufnr integer Buffer holding `from`, captured before the async hop
---@param from string
---@param to string
---@param success_msg string
---@param on_done? fun(ok: boolean) Called once the rename has settled, either way.
local function rename_on_disk(bufnr, from, to, success_msg, on_done)
  local function done(ok)
    if on_done then on_done(ok) end
  end

  if not confirm_overwrite(to) then return done(false) end
  if not ensure_dir(vim.fs.dirname(to)) then return done(false) end

  lsp_will_rename_files(from, to)

  vim.uv.fs_rename(from, to, function(err)
    vim.schedule(function()
      if err then
        notify_error('Rename failed: ' .. tostring(err))
        return done(false)
      end
      lsp_did_rename_files(from, to)

      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_set_name(bufnr, to)
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd('silent! write!')
        end)
      end
      notify_info(success_msg)
      done(true)
    end)
  end)
end

local function create_new_file()
  local _, filepath = current_file()
  if not filepath then return end
  local dir = vim.fs.dirname(filepath)

  vim.ui.input({ prompt = 'New file name: ' }, function(filename)
    if not filename or filename == '' then return end
    local dest = vim.fs.joinpath(dir, filename)
    if not ensure_dir(vim.fs.dirname(dest)) then return end

    create_empty_file(dest, function(err)
      on_created(dest, filename, err)
    end)
  end)
end

local function create_new_file_in_folder()
  vim.ui.input(
    { prompt = 'Relative path from CWD (e.g. src/utils/test.lua): ' },
    function(rel_path)
      if not rel_path or rel_path == '' then return end
      local dest = vim.fs.normalize(vim.fs.abspath(rel_path))
      if not ensure_dir(vim.fs.dirname(dest)) then return end

      create_empty_file(dest, function(err)
        on_created(dest, rel_path, err)
      end)
    end
  )
end

local function duplicate_file()
  local _, src = current_file()
  if not src then return end
  local dir = vim.fs.dirname(src)
  local name = vim.fs.basename(src)

  vim.ui.input({ prompt = 'Duplicate to: ', default = name }, function(new_name)
    if not new_name or new_name == '' or new_name == name then return end
    local dest = vim.fs.joinpath(dir, new_name)
    if not ensure_dir(vim.fs.dirname(dest)) then return end

    vim.uv.fs_copyfile(
      src,
      dest,
      { excl = true, ficlone = false, ficlone_force = false },
      function(err)
        vim.schedule(function()
          if is_eexist(err) then
            notify_warn(new_name .. ' already exists; nothing copied')
            return
          end
          if err then
            notify_error('Duplicate failed: ' .. tostring(err))
            return
          end
          notify_info('Duplicated to: ' .. new_name)
          vim.cmd.edit(vim.fn.fnameescape(dest))
        end)
      end
    )
  end)
end

---@param line1 integer
---@param line2 integer
local function move_selection_to_new_file(line1, line2)
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(bufnr)
  local dir = buf_name ~= '' and vim.fs.dirname(buf_name)
    or (vim.uv.cwd() or '.')

  local s_start, s_end = line1 - 1, line2
  local lines = vim.api.nvim_buf_get_lines(bufnr, s_start, s_end, false)
  if #lines == 0 then
    notify_warn('Selected range is empty')
    return
  end
  local content = table.concat(lines, '\n') .. '\n'

  vim.ui.input({ prompt = 'Move selection to file: ' }, function(filename)
    if not filename or filename == '' then return end
    local dest = vim.fs.joinpath(dir, filename)
    if not ensure_dir(vim.fs.dirname(dest)) then return end

    write_new_file(dest, content, function(err)
      if is_eexist(err) then
        notify_warn(filename .. ' already exists; nothing was moved')
        return
      end
      if err then
        notify_error('Could not create ' .. dest .. ': ' .. tostring(err))
        return
      end
      -- Remove the source lines only once the new file is safely on disk.
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
      if vim.api.nvim_buf_line_count(bufnr) < s_end then
        notify_warn(
          'Wrote '
            .. filename
            .. ', but the buffer changed; source lines left in place'
        )
        return
      end
      vim.api.nvim_buf_set_lines(bufnr, s_start, s_end, false, {})
      notify_info('Moved lines to: ' .. filename)
    end)
  end)
end

local function rename_file()
  local bufnr, src = current_file()
  if not bufnr or not src then return end
  local dir = vim.fs.dirname(src)
  local old_name = vim.fs.basename(src)

  vim.ui.input(
    { prompt = 'Rename file: ', default = old_name },
    function(new_name)
      if not new_name or new_name == '' or new_name == old_name then return end
      rename_on_disk(
        bufnr,
        src,
        vim.fs.joinpath(dir, new_name),
        'Renamed to: ' .. new_name
      )
    end
  )
end

local function move_to_folder_in_cwd()
  local bufnr, src = current_file()
  if not bufnr or not src then return end
  local name = vim.fs.basename(src)

  vim.ui.input(
    { prompt = 'Move to folder (relative to CWD): ' },
    function(rel_dir)
      if not rel_dir or rel_dir == '' then return end
      local target_dir = vim.fs.normalize(vim.fs.abspath(rel_dir))
      rename_on_disk(
        bufnr,
        src,
        vim.fs.joinpath(target_dir, name),
        'Moved file to ' .. rel_dir
      )
    end
  )
end

local function move_and_rename_file()
  local bufnr, src = current_file()
  if not bufnr or not src then return end
  local old_name = vim.fs.basename(src)

  vim.ui.input(
    { prompt = 'Target path/name (relative or absolute): ', default = old_name },
    function(input)
      if not input or input == '' then return end

      local is_dir = input:sub(-1) == '/' or input:sub(-1) == '\\'
      local dest = vim.fs.normalize(vim.fs.abspath(input))
      if is_dir then dest = vim.fs.joinpath(dest, old_name) end

      rename_on_disk(bufnr, src, dest, 'Moved & renamed file to: ' .. dest)
    end
  )
end

local function chmodx()
  local _, src = current_file()
  if not src then return end

  vim.uv.fs_stat(src, function(stat_err, stat)
    if stat_err or not stat then
      vim.schedule(function()
        notify_error('Could not stat ' .. src .. ': ' .. tostring(stat_err))
      end)
      return
    end

    local new_mode = require('bit').bor(stat.mode, tonumber('111', 8))
    vim.uv.fs_chmod(src, new_mode, function(chmod_err)
      vim.schedule(function()
        if chmod_err then
          notify_error('chmod failed: ' .. tostring(chmod_err))
          return
        end
        notify_info('Made executable (+x): ' .. vim.fs.basename(src))
      end)
    end)
  end)
end

---@param bufnr integer
---@param src string
---@param result vim.SystemCompleted
local function on_trash_done(bufnr, src, result)
  vim.schedule(function()
    if result.code ~= 0 then
      notify_error('Trash failed: ' .. vim.trim(result.stderr or ''))
      return
    end
    notify_info('File trashed: ' .. vim.fs.basename(src))
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end)
end

local function trash_file()
  local bufnr, src = current_file()
  if not bufnr or not src then return end

  local sysname = vim.uv.os_uname().sysname

  local function run(cmd)
    vim.system(cmd, {}, function(result)
      on_trash_done(bufnr, src, result)
    end)
  end

  if vim.fn.executable('trash') == 1 then
    run({ 'trash', src })
  elseif sysname == 'Linux' then
    run({ 'gio', 'trash', src })
  elseif sysname == 'Darwin' then
    local escaped = src:gsub('\\', '\\\\'):gsub('"', '\\"')
    run({
      'osascript',
      '-e',
      ('tell application "Finder" to delete POSIX file "%s"'):format(escaped),
    })
  elseif sysname:find('Windows') then
    run({
      'powershell',
      '-NoProfile',
      '-Command',
      (
        'Add-Type -AssemblyName Microsoft.VisualBasic; '
        .. '[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile("%s", "OnlyErrorDialogs", "SendToRecycleBin")'
      ):format(src:gsub('"', '`"')),
    })
  else
    notify_error(
      'Trash is not supported on ' .. sysname .. ' (install the `trash` CLI)'
    )
  end
end

local function show_in_system_explorer()
  local _, src = current_file()
  if not src then return end

  local sysname = vim.uv.os_uname().sysname
  local cmd

  if sysname == 'Darwin' then
    cmd = { 'open', '-R', src }
  elseif sysname:find('Windows') then
    cmd = { 'explorer', '/select,' .. src }
  elseif sysname == 'Linux' then
    cmd = {
      'dbus-send',
      '--session',
      '--print-reply',
      '--dest=org.freedesktop.FileManager1',
      '/org/freedesktop/FileManager1',
      'org.freedesktop.FileManager1.ShowItems',
      'array:string:' .. vim.uri_from_fname(src),
      'string:',
    }
  else
    notify_warn('Revealing files is not supported on ' .. sysname)
    return
  end

  vim.system(cmd, {}, function(result)
    if result.code == 0 or sysname:find('Windows') then return end
    if sysname == 'Linux' then
      vim.system({ 'xdg-open', vim.fs.dirname(src) })
      return
    end
    vim.schedule(function()
      notify_error('Failed to reveal file: ' .. vim.trim(result.stderr or ''))
    end)
  end)
end

---@return integer start_line, integer end_line
local function visual_range()
  local a, b = vim.fn.line('v'), vim.fn.line('.')
  return math.min(a, b), math.max(a, b)
end

vim.api.nvim_create_user_command(
  'CreateNewFile',
  create_new_file,
  { desc = "Create a new file in the current file's directory" }
)
vim.api.nvim_create_user_command(
  'CreateNewFileInFolder',
  create_new_file_in_folder,
  { desc = 'Create a new file at a path under CWD' }
)
vim.api.nvim_create_user_command(
  'DuplicateFile',
  duplicate_file,
  { desc = 'Duplicate the current file' }
)
vim.api.nvim_create_user_command(
  'RenameFile',
  rename_file,
  { desc = 'Rename the current file' }
)
vim.api.nvim_create_user_command(
  'MoveToFolderInCwd',
  move_to_folder_in_cwd,
  { desc = 'Move the current file to a folder under CWD' }
)
vim.api.nvim_create_user_command(
  'MoveAndRenameFile',
  move_and_rename_file,
  { desc = 'Move and rename the current file' }
)
vim.api.nvim_create_user_command(
  'ChmodX',
  chmodx,
  { desc = 'Make the current file executable (chmod +x)' }
)
vim.api.nvim_create_user_command(
  'TrashFile',
  trash_file,
  { desc = 'Move the current file to the system trash' }
)
vim.api.nvim_create_user_command(
  'ShowInSystemExplorer',
  show_in_system_explorer,
  { desc = 'Reveal the current file in the file manager' }
)

vim.api.nvim_create_user_command('MoveSelectionToNewFile', function(args)
  move_selection_to_new_file(args.line1, args.line2)
end, { range = true, desc = 'Move the given line range to a new file' })

local function map(mode, lhs, rhs, desc)
  if lhs then vim.keymap.set(mode, lhs, rhs, { desc = desc }) end
end

map('n', config.keys.create, create_new_file, 'New file')
map(
  'n',
  config.keys.create_in_folder,
  create_new_file_in_folder,
  'New file in folder'
)
map('n', config.keys.duplicate, duplicate_file, 'Duplicate file')
map('n', config.keys.rename, rename_file, 'Rename file')
map(
  'n',
  config.keys.move_to_folder,
  move_to_folder_in_cwd,
  'Move to folder in CWD'
)
map(
  'n',
  config.keys.move_and_rename,
  move_and_rename_file,
  'Move and rename file'
)
map('n', config.keys.chmod_x, chmodx, 'chmod +x')
map('n', config.keys.trash, trash_file, 'Trash file')
map('n', config.keys.reveal, show_in_system_explorer, 'Show in system explorer')
map('x', config.keys.move_selection, function()
  move_selection_to_new_file(visual_range())
end, 'Move selection to new file')
