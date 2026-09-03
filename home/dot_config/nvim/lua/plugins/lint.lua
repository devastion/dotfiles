vim.pack.add(
  { 'https://github.com/mfussenegger/nvim-lint' },
  { confirm = false }
)

if vim.g.autolint == nil then vim.g.autolint = false end

local lint = require('lint')
lint.linters_by_ft = {
  ['*'] = { 'editorconfig-checker' },
  ansible = { 'ansible-lint' },
  bash = { 'shellcheck' },
  css = { 'stylelint' },
  dockerfile = { 'hadolint' },
  gitcommit = { 'gitlint' },
  go = { 'golangci-lint' },
  html = { 'htmlhint' },
  javascript = { 'eslint_d' },
  javascriptreact = { 'eslint_d' },
  json = { 'jsonlint' },
  lua = { 'selene' },
  make = { 'checkmake' },
  markdown = { 'rumdl', 'markdownlint-cli2', 'vale' },
  proto = { 'protolint' },
  python = { 'mypy' },
  scss = { 'stylelint' },
  sh = { 'shellcheck' },
  sql = { 'sqlfluff' },
  svelte = { 'eslint_d' },
  terraform = { 'tflint' },
  typescript = { 'eslint_d' },
  typescriptreact = { 'eslint_d' },
  yaml = { 'yamllint' },
  zsh = { 'shellcheck' },
}

require('plugins.mason').install(require('lint').linters_by_ft)

vim.keymap.set('n', '<leader>cl', function()
  local names = lint.linters_by_ft[vim.bo.filetype] or {}
  names = vim.list_extend({}, names)
  vim.list_extend(names, lint.linters_by_ft['*'] or {})

  if #names > 0 then lint.try_lint(names) end
end, { desc = 'Lint Buffer' })

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost' }, {
  group = vim.api.nvim_create_augroup('devastion.lint', { clear = true }),
  desc = 'Lint on read and write',
  callback = function()
    if vim.bo.buftype ~= '' then return end

    local global = vim.g.autolint
    local buffer = vim.b.autolint

    if global == false or buffer == false then return end

    lint.try_lint()
  end,
})

vim.api.nvim_create_user_command('Lint', function()
  lint.try_lint()
end, {})
