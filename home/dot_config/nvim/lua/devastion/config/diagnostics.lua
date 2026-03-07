local map = require("devastion.utils").map

vim.diagnostic.config({
  signs = { text = vim.g.diagnostic_signs },
  float = {
    source = false,
    border = vim.g.border_style,
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

local function diagnostic_goto(next, severity)
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    vim.diagnostic.jump({ count = next and 1 or -1, float = true, severity = severity })
  end
end

map("]d", diagnostic_goto(true), "Next Diagnostic")
map("[d", diagnostic_goto(false), "Prev Diagnostic")
map("]e", diagnostic_goto(true, "ERROR"), "Next Error")
map("[e", diagnostic_goto(false, "ERROR"), "Prev Error")
map("]w", diagnostic_goto(true, "WARN"), "Next Warning")
map("[w", diagnostic_goto(false, "WARN"), "Prev Warning")

map("<leader>cd", function()
  vim.diagnostic.open_float({ border = vim.g.border_style })
end, "Line Diagnostics")
map("<leader>cq", function()
  vim.diagnostic.setqflist({ border = vim.g.border_style })
end, "Diagnostics to qf")
