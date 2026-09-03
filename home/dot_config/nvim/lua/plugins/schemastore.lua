vim.pack.add({
  'https://github.com/b0o/schemastore.nvim',
}, { confirm = false })

vim.lsp.config('json_ls', {
  settings = {
    json = {
      validate = {
        enable = true,
      },
    },
  },
  before_init = function(_, config)
    config.settings.json.schemas = require('schemastore').json.schemas()
  end,
})

vim.lsp.config('yaml_ls', {
  settings = {
    yaml = {
      schemaStore = {
        enable = false,
        url = '',
      },
    },
  },
  before_init = function(_, config)
    config.settings.yaml.schemas = require('schemastore').yaml.schemas()
  end,
})
