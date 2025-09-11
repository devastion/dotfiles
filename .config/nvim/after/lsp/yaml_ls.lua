vim.g.mason_install({ "yaml-language-server" })
vim.g.ts_install({ "yaml" })

---@type vim.lsp.Config
return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml" },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      keyOrdering = false,
      format = {
        enable = true,
      },
      validate = true,
      schemaStore = {
        -- Must disable built-in schemaStore support to use
        -- schemas from SchemaStore.nvim plugin
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = "",
      },
    },
  },
  before_init = function(_, config)
    config.settings.yaml.schemas = config.settings.yaml.schemas or {}
    vim.list_extend(config.settings.yaml.schemas, require("schemastore").yaml.schemas())
  end,
  root_markers = { ".git" },
  on_init = function(client) client.server_capabilities.documentFormattingProvider = true end,
}
