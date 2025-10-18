vim.g.mason_install({ "intelephense", "pint", "blade-formatter", "phpcs", "php-cs-fixer" })
vim.g.ts_install({ "php", "php_only", "phpdoc", "blade" })

require("conform").formatters_by_ft.php = vim.g.is_laravel_project and { "pint" } or { "php_cs_fixer" }
require("conform").formatters_by_ft.blade = { "blade-formatter" }
require("lint").linters_by_ft.php = vim.g.is_laravel_project and {} or { "phpcs" }

local map = require("devastion.utils").remap

map(
  "<leader>fc",
  function()
    require("fzf-lua").files({
      cmd = "fd -g -p -t f '**/controllers/**'",
    })
  end,
  "Controllers",
  "n",
  { buffer = true }
)
map(
  "<leader>fm",
  function()
    require("fzf-lua").files({
      cmd = "fd -g -p -t f '**/models/**'",
    })
  end,
  "Models",
  "n",
  { buffer = true }
)
map(
  "<leader>fs",
  function()
    require("fzf-lua").files({
      cmd = "fd -g -p -t f '**/services/**' --exclude='tests'",
    })
  end,
  "Services",
  "n",
  { buffer = true }
)
map(
  "<leader>ft",
  function()
    require("fzf-lua").files({
      cmd = "fd -g -p -t f '**/tests/**'",
    })
  end,
  "Tests",
  "n",
  { buffer = true }
)
