local utils = require("devastion.utils")

vim.lsp.enable(utils.get_lsp_configs())

local disabled_lsp = {
  tailwindcss_ls = vim.g.is_tailwind_project,
}
for k, v in pairs(disabled_lsp) do
  vim.lsp.enable(k, v)
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

-- On LSP Attach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
  desc = "LSP Keymaps",
  callback = function(event)
    local map = utils.remap

    local client_id = vim.tbl_get(event, "data", "client_id")
    local client = vim.lsp.get_client_by_id(client_id)

    -- Use ESLint as formatter
    if client ~= nil then
      if client:supports_method(vim.lsp.protocol.Methods.textDocument_foldingRange) then
        vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
      end

      local disabled_formatting_lsp = { "vue_ls", "ts_ls" }
      if client.name == "eslint_ls" then
        client.server_capabilities.documentFormattingProvider = true
      elseif utils.table_contains(disabled_formatting_lsp, client.name) then
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
      "<C-k>",
      function() vim.lsp.buf.signature_help({ border = "single" }) end,
      "LSP: Signature Help",
      { "i", "s" },
      opts
    )
    map("gK", function() vim.lsp.buf.signature_help({ border = "single" }) end, "LSP: Signature Help", "n", opts)
    map("K", function() vim.lsp.buf.hover({ border = "single" }) end, "LSP: Hover", "n", opts)
    map("gd", function() vim.lsp.buf.definition() end, "LSP: Goto Definition", "n", opts)
    map("grt", function() vim.lsp.buf.type_definition() end, "LSP: Goto Type Definition", "n", opts)
    map("grd", function() vim.lsp.buf.declaration() end, "LSP: Goto Declaration", "n", opts)
    map("gq", function() vim.lsp.buf.format({ async = true }) end, "LSP: Format", "n", opts)
    map("grc", function() vim.lsp.codelens.run() end, "LSP: Run Codelens", "n", opts)
    map("grC", function() vim.lsp.codelens.refresh() end, "LSP: Refresh and Display Codelens", "n", opts)

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
