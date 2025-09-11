vim.g.mason_install({ "json-lsp" })
vim.g.ts_install({ "json", "jsonc", "json5" })

---@type vim.lsp.Config
return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  init_options = {
    provideFormatter = true,
  },
  settings = {
    json = {
      format = {
        enable = true,
      },
      validate = { enable = true },
    },
  },
  before_init = function(_, config)
    config.settings.json.schemas = config.settings.json.schemas or {}
    vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
  end,
  root_markers = { ".git" },
}
