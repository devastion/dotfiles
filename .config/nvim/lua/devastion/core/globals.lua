vim.g.mapleader = vim.keycode("<space>")
vim.g.maplocalleader = vim.keycode("<bslash>")

vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.g.autolint_enabled = true
vim.g.autoformat_enabled = false
vim.g.phpunit_cmd = vim.env.HOME .. "/.local/bin/dphpunit"

vim.g.ui_border = "single"

local utils = require("devastion.utils")

vim.g.remap = utils.remap
vim.g.custom_foldtext = require("devastion.helpers.misc").custom_foldtext
vim.g.diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = "✘",
  [vim.diagnostic.severity.WARN] = "▲",
  [vim.diagnostic.severity.HINT] = "⚑",
  [vim.diagnostic.severity.INFO] = "»",
}
vim.g.disabled_lsp = { "cspell-lsp" }

vim.g.is_laravel_project = utils.package_exists("composer.json", '.require."laravel/framework"')

vim.g.treesitter_ensure_installed = {
  "bash",
  "blade",
  "c",
  "cpp",
  "css",
  "dap_repl",
  "diff",
  "dockerfile",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "graphql",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "jsonc",
  "latex",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "norg",
  "php",
  "php_only",
  "phpdoc",
  "printf",
  "python",
  "query",
  "regex",
  "scss",
  "sql",
  "svelte",
  "toml",
  "tsx",
  "typescript",
  "typst",
  "vim",
  "vimdoc",
  "vue",
  "xml",
  "yaml",
}
vim.g.treesitter_ignored = { "tmux" }

vim.g.mason_ensure_installed = {
  "actionlint",
  "ansible-language-server",
  "ansible-lint",
  "basedpyright",
  "bash-language-server",
  "black",
  "blade-formatter",
  "clangd",
  "cspell",
  "cspell-lsp",
  "css-lsp",
  "debugpy",
  "docker-language-server",
  "dotenv-linter",
  "eslint-lsp",
  "graphql-language-service-cli",
  "hadolint",
  "html-lsp",
  "intelephense",
  "js-debug-adapter",
  "json-lsp",
  "lua-language-server",
  "markdown-toc",
  "markdownlint-cli2",
  "marksman",
  "php-cs-fixer",
  "php-debug-adapter",
  "phpcs",
  "pint",
  "prettier",
  "ruff",
  "shellcheck",
  "shfmt",
  "sqlfluff",
  "stylua",
  "taplo",
  "typescript-language-server",
  "vue-language-server",
  "yaml-language-server",
}
