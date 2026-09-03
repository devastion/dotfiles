vim.pack.add({
  'https://github.com/nvim-mini/mini.files',
}, { confirm = false })

local mini_files = require('mini.files')

mini_files.setup({
  windows = {
    preview = true,
    width_focus = 20,
    width_nofocus = 20,
    width_preview = 80,
  },
  options = {
    permanent_delete = false,
    use_as_default_explorer = true,
  },
})

---@param from string
---@param to string
local lsp_rename_file = function(from, to)
  local params = {
    files = {
      {
        oldUri = vim.uri_from_fname(from),
        newUri = vim.uri_from_fname(to),
      },
    },
  }
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client:supports_method('workspace/willRenameFiles') then
      local res =
        client:request_sync('workspace/willRenameFiles', params, 1000, 0)
      if res and res.result then
        vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding)
      end
    end
  end
end

local group =
  vim.api.nvim_create_augroup('devastion.mini_files', { clear = true })

vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'MiniFilesActionRename',
  callback = function(ev)
    pcall(lsp_rename_file, ev.data.from, ev.data.to)
  end,
  desc = 'LSP-aware file rename',
})

vim.keymap.set('n', '<Leader>e', function()
  mini_files.open(nil, false)
end, { desc = 'Files (cwd)' })
vim.keymap.set('n', '<Leader>E', function()
  mini_files.open(vim.api.nvim_buf_get_name(0), false)
end, { desc = 'Files (buffer dir)' })

local filter_show = function(_fs_entry)
  return true
end

local filter_hide = function(fs_entry)
  return not vim.startswith(fs_entry.name, '.')
end

local show_dotfiles = true
local toggle_dotfiles = function()
  show_dotfiles = not show_dotfiles
  local new_filter = show_dotfiles and filter_show or filter_hide
  mini_files.refresh({ content = { filter = new_filter } })
  vim.notify(
    ('Toggled dotfiles (%s)'):format(show_dotfiles and 'enabled' or 'disabled'),
    vim.log.levels.INFO,
    { title = 'Toggle' }
  )
end

local map_split = function(buf_id, lhs, direction)
  local rhs = function()
    local cur_target = mini_files.get_explorer_state().target_window
    local new_target = vim.api.nvim_win_call(cur_target, function()
      vim.cmd(direction .. ' split')
      return vim.api.nvim_get_current_win()
    end)

    mini_files.set_target_window(new_target)
    mini_files.go_in({ close_on_file = true })
  end

  local desc = 'Split ' .. direction
  vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
end

local set_cwd = function()
  local path = (mini_files.get_fs_entry() or {}).path
  if path == nil then return vim.notify('Cursor is not on valid entry') end
  local dir = vim.fs.dirname(path)
  vim.fn.chdir(dir)
  vim.notify(
    'Changed directory 󰁕 ' .. dir,
    vim.log.levels.INFO,
    { title = 'Neovim' }
  )
end

local yank_path = function()
  local path = (mini_files.get_fs_entry() or {}).path
  if path == nil then return vim.notify('Cursor is not on valid entry') end
  vim.fn.setreg(vim.v.register, path)
end

local ui_open = function()
  vim.ui.open(mini_files.get_fs_entry().path)
end

vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'MiniFilesBufferCreate',
  desc = 'Extra mini.files buffer mappings',
  callback = function(args)
    local buf_id = args.data.buf_id
    vim.keymap.set(
      'n',
      'g.',
      toggle_dotfiles,
      { buffer = buf_id, desc = 'Toggle dotfiles' }
    )
    vim.keymap.set('n', 'g~', set_cwd, { buffer = buf_id, desc = 'Set cwd' })
    vim.keymap.set('n', 'gX', ui_open, { buffer = buf_id, desc = 'OS open' })
    vim.keymap.set(
      'n',
      'gy',
      yank_path,
      { buffer = buf_id, desc = 'Yank path' }
    )
    map_split(buf_id, '<C-s>', 'belowright horizontal')
    map_split(buf_id, '<C-v>', 'belowright vertical')
    map_split(buf_id, '<C-t>', 'tab')
  end,
})
