vim.g.mason_install({ "bash-language-server", "shfmt", "shellcheck" })
vim.g.ts_install({ "bash" })

require("conform").formatters_by_ft.sh = { "shfmt" }
require("conform").formatters_by_ft.bash = { "shfmt" }
require("lint").linters_by_ft.sh = { "shellcheck" }
require("lint").linters_by_ft.bash = { "shellcheck" }

---@type vim.lsp.Config
return {
  cmd = { "bash-language-server", "start" },
  settings = {
    bashIde = {
      globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
    },
  },
  filetypes = { "bash", "sh" },
  root_markers = { ".git" },
}
