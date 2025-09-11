vim.g.mason_install({ "graphql-language-service-cli", "prettier" })
vim.g.ts_install({ "graphql" })
require("conform").formatters_by_ft.graphql = { "prettier" }

---@type vim.lsp.Config
return {
  cmd = { "graphql-lsp", "server", "-m", "stream" },
  filetypes = { "graphql", "typescriptreact", "javascriptreact" },
  root_markers = { ".graphqlrc*", ".graphql.config.*", "graphql.config.*" },
}
