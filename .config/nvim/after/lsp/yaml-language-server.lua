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
        enable = false,
        url = "",
      },
    },
  },
  before_init = function(_, config)
    config.settings.yaml.schemas = config.settings.yaml.schemas or {}
    vim.list_extend(config.settings.yaml.schemas, require("schemastore").yaml.schemas())
  end,
  root_markers = { ".git" },
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = true
  end,
}
