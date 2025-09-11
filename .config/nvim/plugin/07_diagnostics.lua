---Check if table contains value
---@param table table
---@param value string|number
---@return boolean
local table_contains = function(table, value)
  for i = 1, #table do
    if table[i] == value then
      return true
    end
  end

  return false
end

---Get all configurations in lsp/*
---@return table
local get_lsp_configs = function()
  local lsp_configs = {}

  for _, v in ipairs(vim.api.nvim_get_runtime_file("lsp/*", true)) do
    local name = vim.fn.fnamemodify(v, ":t:r")
    table.insert(lsp_configs, name)
  end

  return lsp_configs
end
vim.lsp.enable(get_lsp_configs())

-- INFO: Temporary disabled
local disabled_lsp = { "tailwindcss_ls" }
for _k, v in pairs(disabled_lsp) do
  vim.lsp.enable(v, false)
end

local diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = "✘",
  [vim.diagnostic.severity.WARN] = "▲",
  [vim.diagnostic.severity.HINT] = "⚑",
  [vim.diagnostic.severity.INFO] = "»",
}

-- Setup diagnostics
vim.diagnostic.config({
  signs = { text = diagnostic_signs },
  float = {
    source = false,
    border = "single",
    suffix = "",
    prefix = "",
    format = function(d)
      local code = d.code or vim.tbl_get(d, "user_data", "lsp", "code")
      return code and string.format("%s (%s) [%s]", d.message, d.source, code)
        or string.format("%s (%s)", d.message, d.source)
    end,
  },
  underline = false,
  virtual_lines = false,
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
    current_line = false,
    prefix = " ",
    severity_sort = true,
    source = false,
  },
  update_in_insert = false,
  severity_sort = true,
})

-- On LSP attach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
  desc = "LSP keymaps",
  callback = function(event)
    local map = function(lhs, rhs, desc, mode, opts)
      opts = opts or {}
      opts.desc = desc
      mode = mode or "n"
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    local client_id = vim.tbl_get(event, "data", "client_id")
    local client = vim.lsp.get_client_by_id(client_id)

    -- Use ESLint as formatter
    if client ~= nil then
      local disabled_formatting_lsp = { "vue_ls", "ts_ls" }
      if client.name == "eslint_ls" then
        client.server_capabilities.documentFormattingProvider = true
      elseif table_contains(disabled_formatting_lsp, client.name) then
        client.server_capabilities.documentFormattingProvider = false
      end
    end

    local opts = { buffer = event.buf }
    map("grr", function() vim.lsp.buf.references() end, "References", "n", opts)
    map("gri", function() vim.lsp.buf.implementation() end, "Implementation", "n", opts)
    map("grn", function() vim.lsp.buf.rename() end, "Rename", "n", opts)
    map("gra", function() vim.lsp.buf.code_action() end, "Code Action", "n", opts)
    map(
      "grA",
      function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source" },
            diagnostics = {},
          },
        })
      end,
      "Source Code Action",
      "n",
      opts
    )
    map("g0", function() vim.lsp.buf.document_symbol() end, "LSP: Document Symbol", "n", opts)
    map(
      "<C-s>",
      function() vim.lsp.buf.signature_help({ border = "single" }) end,
      "LSP: Signature Help",
      { "i", "s" },
      opts
    )
    map("K", function() vim.lsp.buf.hover({ border = "single" }) end, "LSP: Hover", "n", opts)
    map("gd", function() vim.lsp.buf.definition() end, "LSP: Goto Definition", "n", opts)
    map("grt", function() vim.lsp.buf.type_definition() end, "LSP: Goto Type Definition", "n", opts)
    map("grd", function() vim.lsp.buf.declaration() end, "LSP: Goto Declaration", "n", opts)
    map("gq", function() vim.lsp.buf.format({ async = true }) end, "LSP: Format", "n", opts)
    map(
      "<leader>cd",
      function() vim.diagnostic.open_float({ border = "single" }) end,
      "LSP: Line Diagnostics",
      "n",
      opts
    )
    map(
      "<leader>cq",
      function() vim.diagnostic.setloclist({ border = "single" }) end,
      "LSP: Diagnostics to QF",
      "n",
      opts
    )

    -- fzf-lua
    local fzf = require("fzf-lua")
    map("grr", function() fzf.lsp_references({ ignore_current_line = true }) end, "References", "n", opts)
    map("gri", function() fzf.lsp_implementations() end, "Implementation", "n", opts)
    map(
      "gra",
      function()
        fzf.lsp_code_actions({
          winopts = {
            relative = "cursor",
            width = 0.6,
            height = 0.6,
            row = 1,
            preview = { vertical = "up:70%" },
          },
        })
      end,
      "Code Action",
      "n",
      opts
    )
    map("g0", function() fzf.lsp_document_symbols() end, "LSP: Document Symbol", "n", opts)
    map("gd", function() fzf.lsp_definitions({ jump1 = true }) end, "LSP: Goto Definition", "n", opts)
    map("grt", function() fzf.lsp_typedefs() end, "LSP: Goto Type Definition", "n", opts)
    map("grd", function() fzf.lsp_declarations() end, "LSP: Goto Declaration", "n", opts)
    map(
      "grn",
      function() return ":IncRename " .. vim.fn.expand("<cword>") end,
      "LSP: Incremental Rename",
      "n",
      { buffer = event.buf, desc = "Incremental Rename", expr = true }
    )
  end,
})
