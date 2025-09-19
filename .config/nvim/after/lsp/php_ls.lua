vim.g.mason_install({ "intelephense", "pint", "blade-formatter", "phpcs", "php-cs-fixer" })
vim.g.ts_install({ "php", "php_only", "phpdoc", "blade" })

require("conform").formatters_by_ft.php = vim.g.is_laravel_project and { "pint" } or { "php_cs_fixer" }
require("conform").formatters_by_ft.blade = { "blade-formatter" }
require("lint").linters_by_ft.php = vim.g.is_laravel_project and {} or { "phpcs" }

---@type vim.lsp.Config
return {
  cmd = { "intelephense", "--stdio" },
  filetypes = { "php" },
  root_markers = { ".git", "composer.json" },
}
