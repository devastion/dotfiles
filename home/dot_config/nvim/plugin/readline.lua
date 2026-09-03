local map = vim.keymap.set

-- Insert mode
map('i', '<C-a>', '<Home>', { desc = 'Move to beginning of line' })
map('i', '<C-e>', '<End>', { desc = 'Move to end of line' })
map('i', '<C-b>', '<Left>', { desc = 'Move back one character' })
map('i', '<C-f>', '<Right>', { desc = 'Move forward one character' })

map('i', '<M-b>', '<C-Left>', { desc = 'Move back one word' })
map('i', '<M-f>', '<C-Right>', { desc = 'Move forward one word' })

map('i', '<C-d>', '<Del>', { desc = 'Delete character under cursor' })
map('i', '<C-h>', '<BS>', { desc = 'Delete character before cursor' })

map('i', '<C-n>', '<Down>', { desc = 'Next line' })
map('i', '<C-p>', '<Up>', { desc = 'Previous line' })

map('i', '<C-k>', '<C-o>D', { desc = 'Delete to end of line' })
map('i', '<C-u>', '<C-o>d0', { desc = 'Delete to beginning of line' })

map('i', '<C-w>', '<C-w>', { desc = 'Delete word before cursor' })

map('i', '<M-d>', '<C-o>dw', { desc = 'Delete word after cursor' })

map('i', '<M-BS>', '<C-w>', { desc = 'Delete word before cursor' })

-- Commandline mode
map('c', '<C-a>', '<Home>', { desc = 'Move to beginning of line' })
map('c', '<C-e>', '<End>', { desc = 'Move to end of line' })
map('c', '<C-b>', '<Left>', { desc = 'Move back one character' })
map('c', '<C-f>', '<Right>', { desc = 'Move forward one character' })

map('c', '<M-b>', '<C-Left>', { desc = 'Move back one word' })
map('c', '<M-f>', '<C-Right>', { desc = 'Move forward one word' })

map('c', '<C-d>', '<Del>', { desc = 'Delete character under cursor' })
map('c', '<C-h>', '<BS>', { desc = 'Delete character before cursor' })

map('c', '<C-n>', '<Down>', { desc = 'Next history item' })
map('c', '<C-p>', '<Up>', { desc = 'Previous history item' })

map('c', '<C-k>', function()
  local line = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()

  local before = line:sub(1, pos - 1)

  vim.fn.setcmdline(before)
end, { desc = 'Delete to end of line' })

map('c', '<C-u>', function()
  local line = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()

  local after = line:sub(pos)

  vim.fn.setcmdline(after)
end, { desc = 'Delete to beginning of line' })

map('c', '<C-w>', function()
  local line = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()

  local before = line:sub(1, pos - 1)
  local after = line:sub(pos)

  before = before:gsub('%s+$', '')
  before = before:gsub('%S+$', '')

  vim.fn.setcmdline(before .. after, #before + 1)
end, { desc = 'Delete word before cursor' })
