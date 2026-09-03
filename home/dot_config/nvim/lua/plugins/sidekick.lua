-- vim.pack.add({ 'https://github.com/folke/sidekick.nvim' }, { confirm = false })
vim.pack.add({
  {
    src = 'https://github.com/seflue/sidekick.nvim',
    version = 'fix/tmux-duplicate-pane-id',
  },
}, { confirm = false })

require('sidekick').setup({
  nes = { enabled = false },
  cli = {
    win = {
      layout = 'float',
    },
    mux = {
      enabled = true,
    },
    prompts = {
      refactor = 'Please refactor {this} to be more maintainable',
      security = 'Review {file} for security vulnerabilities',
      enhance = 'Review, refactor, optimize, enhance and apply bug fixes to {file}',
    },
  },
})

local map = vim.keymap.set

local cli = require('sidekick.cli')

map({ 'n', 't', 'i', 'x' }, '<C-.>', function()
  cli.toggle()
end, { desc = 'Toggle sidekick' })

map('n', '<leader>aa', function()
  cli.toggle()
end, { desc = 'Toggle CLI' })
map('n', '<leader>as', function()
  cli.select({ filter = { installed = true } })
end, { desc = 'Select CLI' })
map('n', '<leader>ad', function()
  cli.close()
end, { desc = 'Close CLI Session' })
map({ 'n', 'x' }, '<leader>at', function()
  cli.send({ msg = '{this}' })
end, { desc = 'Send This' })
map('n', '<leader>af', function()
  cli.send({ msg = '{file}' })
end, { desc = 'Send File' })
map('x', '<leader>av', function()
  cli.send({ msg = '{selection}' })
end, { desc = 'Send Visual Selection' })
map({ 'n', 'x' }, '<leader>ap', function()
  cli.prompt()
end, { desc = 'Select Prompt' })
