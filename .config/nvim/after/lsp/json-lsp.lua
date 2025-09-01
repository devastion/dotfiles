return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  init_options = {
    provideFormatter = true,
  },
  settings = {
    json = {
      ---@diagnostic disable-next-line: undefined-field
      schemas = require("schemastore").json.schemas(),
      format = {
        enable = true,
      },
      validate = { enable = true },
    },
  },
  root_markers = { ".git" },
}
