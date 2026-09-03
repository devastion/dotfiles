local mappings = {
  d = 'drop',
  e = 'edit',
  f = 'fixup',
  p = 'pick',
  r = 'reword',
  s = 'squash',
}

for key, action in pairs(mappings) do
  vim.keymap.set('n', key, function()
    local cursor_position = vim.api.nvim_win_get_cursor(0)
    vim.cmd.normal({ args = { 'ciw' .. action }, bang = true })
    vim.api.nvim_win_set_cursor(0, cursor_position)
  end, { buf = 0, desc = 'Change to ' .. action })
end
