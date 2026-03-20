local map = require("devastion.utils").map

vim.diagnostic.config({
  signs = vim.g.diagnostic_signs and { text = vim.g.diagnostic_signs } or true,
  float = {
    source = false,
    border = vim.g.border_style,
    suffix = "",
    prefix = "",
    format = function(d)
      local code = d.code or vim.tbl_get(d, "user_data", "lsp", "code")
      if d.source then
        return code and string.format("%s (%s) [%s]", d.message, d.source, code)
          or string.format("%s (%s)", d.message, d.source)
      end
      return d.message
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
  local sev = severity and vim.diagnostic.severity[severity] or nil
  return function()
    vim.diagnostic.jump({
      count = next and 1 or -1,
      float = true,
      severity = sev,
    })
  end
end

local diagnostics_keymaps = {
  {
    key = "]d",
    desc = "Next Diagnostic",
    cmd = diagnostic_goto(true),
  },
  {
    key = "[d",
    desc = "Prev Diagnostic",
    cmd = diagnostic_goto(false),
  },
  {
    key = "]e",
    desc = "Next Error",
    cmd = diagnostic_goto(true, "ERROR"),
  },
  {
    key = "[e",
    desc = "Prev ERROR",
    cmd = diagnostic_goto(false, "ERROR"),
  },
  {
    key = "]w",
    desc = "Next Warning",
    cmd = diagnostic_goto(true, "WARN"),
  },
  {
    key = "[w",
    desc = "Prev Warning",
    cmd = diagnostic_goto(false, "WARN"),
  },
  {
    key = "<leader>cd",
    desc = "Line Diagnostic",
    cmd = function()
      vim.diagnostic.open_float({ border = vim.g.border_style })
    end,
  },
  {
    key = "<leader>cq",
    desc = "Diagnostics to quickfix",
    cmd = function()
      vim.diagnostic.setqflist()
    end,
  },
}

for i, v in pairs(diagnostics_keymaps) do
  map(v.key, v.cmd, v.desc)
end
