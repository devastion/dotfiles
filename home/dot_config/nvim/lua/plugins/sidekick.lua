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
      refactor = 'Please refactor {this} to be more maintainable, without changing its behavior',
      simplify = 'Simplify {this} — remove unnecessary complexity while keeping the same output',
      rename = 'Suggest better, more descriptive names for the variables and functions in {this}',

      security = 'Review {file} for security vulnerabilities and explain the risk of each one found',
      review = 'Review {file} as a strict senior engineer would — flag correctness, edge cases, and anything risky in production',
      enhance = 'Review, refactor, optimize, enhance and apply bug fixes to {file}',

      explain = 'Explain what {this} does, step by step, including any non-obvious edge cases',
      explain_file = 'Explain the overall purpose and structure of {file}',

      add_tests = 'Write unit tests for {this}, covering the happy path, edge cases, and failure modes',
      fix_tests = 'Run the test suite for {file} and fix any failing tests without changing intended behavior',

      fix_bug = 'There is a bug in {this} — find the root cause and fix it, then explain what was wrong',
      fix_diagnostics = 'Fix the LSP diagnostics/errors currently shown in {file}',

      document = 'Add clear docstrings/comments to {this}, documenting parameters, return values, and any gotchas',

      optimize = 'Profile {this} for performance issues and optimize the slowest part',

      types = 'Tighten the TypeScript types in {this} — remove any `any`, add missing generics, and fix incorrect signatures',

      commit_msg = 'Write a conventional-commit message summarizing the staged changes',
      pr_summary = 'Summarize the current diff as a pull request description, including what changed and why',
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
