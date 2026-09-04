vim.pack.add(
  { 'https://github.com/stevearc/conform.nvim' },
  { confirm = false }
)

if vim.g.autoformat == nil then vim.g.autoformat = false end

local conform = require('conform')

conform.setup({
  default_format_opts = {
    timeout_ms = 1000,
    async = false,
    quiet = false,
    lsp_format = 'fallback',
    stop_after_first = false,
  },
  formatters_by_ft = {
    ['_'] = { 'trim_whitespace', 'trim_newlines' },
    bash = { 'shfmt' },
    c = { 'clang_format' },
    cmake = { 'gersemi' },
    cpp = { 'clang_format' },
    css = { 'prettierd' },
    go = { 'goimports', 'gofumpt', 'golines' },
    graphql = { 'prettierd' },
    html = { 'prettierd' },
    htmldjango = { 'djlint' },
    javascript = { 'prettierd' },
    javascriptreact = { 'prettierd' },
    json = { 'json_repair', 'jq' },
    jsonc = { 'biome', stop_after_first = true },
    ksh = { 'shfmt' },
    lua = { 'stylua' },
    markdown = { 'mdformat', injected = true },
    php = { 'pint' },
    proto = { 'buf' },
    python = { 'isort', 'black' },
    scss = { 'prettierd' },
    sh = { 'shfmt' },
    sql = { 'sql_formatter' },
    svelte = { 'prettierd' },
    toml = { 'taplo' },
    typescript = { 'prettierd' },
    typescriptreact = { 'prettierd' },
    vue = { 'prettierd', stop_after_first = true },
    xml = { 'xmlformatter' },
    yaml = { 'yamlfmt' },
    zsh = { 'shfmt' },
  },
  format_on_save = function(bufnr)
    if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
      return
    end

    return {
      timeout_ms = 500,
      lsp_format = 'fallback',
    }
  end,
  formatters = {
    injected = { options = { ignore_errors = true } },
  },
})

local mason_formatters = vim.deepcopy(conform.formatters_by_ft)
mason_formatters['_'] = nil
require('plugins.mason').install(mason_formatters)

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.keymap.set({ 'n' }, '<leader>cf', function()
  conform.format({ async = true })
end, { desc = 'Format buffer' })
vim.keymap.set({ 'n' }, '<leader>cF', function()
  conform.format({ formatters = { 'injected' } })
end, { desc = 'Format injected langs' })
vim.keymap.set({ 'x' }, '<leader>cf', function()
  local start_line = vim.fn.line('v')
  local end_line = vim.fn.line('.')
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local last_line =
    vim.api.nvim_buf_get_lines(0, end_line - 1, end_line, true)[1]

  conform.format({
    range = {
      start = { start_line, 0 },
      ['end'] = { end_line, last_line:len() },
    },
  })
end, { desc = 'Format selection' })

vim.api.nvim_create_user_command('Format', function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line =
      vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ['end'] = { args.line2, end_line:len() },
    }
  end
  conform.format({
    async = true,
    lsp_format = 'fallback',
    range = range,
  })
end, { range = true })
