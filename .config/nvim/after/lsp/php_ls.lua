vim.g.mason_install({ "intelephense", "pint", "blade-formatter", "phpcs", "php-cs-fixer" })
vim.g.ts_install({ "php", "php_only", "phpdoc", "blade" })

---Checks if composer.json contains laravel/framework
---@return boolean
local laravel = (function()
  local composer = vim.fn.getcwd() .. "/composer.json"
  local is_readable = vim.fn.filereadable(composer) ~= 0

  if is_readable then
    local is_laravel = vim.system({ "jq", '.require."laravel/framework"', composer }, {}):wait().stdout
    if is_laravel then
      return true
    end
  end

  return false
end)()

require("conform").formatters_by_ft.php = laravel and { "pint" } or { "php_cs_fixer" }
require("conform").formatters_by_ft.blade = { "blade-formatter" }
require("lint").linters_by_ft.php = laravel and {} or { "phpcs" }

---@type vim.lsp.Config
return {
  cmd = { "intelephense", "--stdio" },
  filetypes = { "php" },
  root_markers = { ".git", "composer.json" },
}
