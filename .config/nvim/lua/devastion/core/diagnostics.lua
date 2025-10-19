local utils = require("devastion.utils")
local map = vim.g.remap

-- Setup diagnostics
vim.diagnostic.config({
  signs = { text = utils.diagnostic_signs },
  float = {
    source = false,
    border = vim.g.ui_border,
    suffix = "",
    prefix = "",
    format = function(d)
      local code = d.code or vim.tbl_get(d, "user_data", "lsp", "code")
      return code and string.format("%s (%s) [%s]", d.message, d.source, code)
        or string.format("%s (%s)", d.message, d.source)
    end,
  },
  underline = {
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
  },
  virtual_lines = false,
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
    current_line = nil,
    prefix = " ",
    severity_sort = true,
    source = false,
  },
  update_in_insert = false,
  severity_sort = true,
})

map("]e", function()
  vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR })
end, "Next Error", "n")
map("[e", function()
  vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
end, "Prev Error", "n")
map("]w", function()
  vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.WARN })
end, "Next Warning", "n")
map("[w", function()
  vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.WARN })
end, "Prev Warning", "n")
