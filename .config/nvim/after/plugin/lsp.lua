local utils = require("devastion.utils")
local map = vim.g.remap
local lsp_configs = require("devastion.helpers.lsp").get_lsp_configs()

vim.lsp.enable(utils.filter_table_items(lsp_configs, vim.g.disabled_lsp))

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
  callback = function(event)
    local client_id = vim.tbl_get(event, "data", "client_id")
    local client = vim.lsp.get_client_by_id(client_id)

    if client ~= nil then
      if client:supports_method(vim.lsp.protocol.Methods.textDocument_foldingRange) then
        local win = vim.api.nvim_get_current_win()
        vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
      end

      local disabled_formatting_lsp = { "vue-language-server", "typescript-language-server" }
      if client.name == "eslint-lsp" then
        client.server_capabilities.documentFormattingProvider = true
      elseif utils.table_contains(disabled_formatting_lsp, client.name) then
        client.server_capabilities.documentFormattingProvider = false
      end
    end

    local opts = { buffer = event.buf }

    map("grr", function()
      vim.lsp.buf.references()
    end, "References", "n", opts)
    map("gri", function()
      vim.lsp.buf.implementation()
    end, "Implementation", "n", opts)
    map("grn", function()
      vim.lsp.buf.rename()
    end, "Rename", "n", opts)
    map("gra", function()
      vim.lsp.buf.code_action()
    end, "Code Action", "n", opts)
    map("grA", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source" },
          diagnostics = {},
        },
      })
    end, "Source Code Action", "n", opts)
    map("g0", function()
      vim.lsp.buf.document_symbol()
    end, "LSP: Document Symbol", "n", opts)
    map("<c-k>", function()
      vim.lsp.buf.signature_help({ border = vim.g.ui_border })
    end, "LSP: Signature Help", { "i", "s" }, opts)
    map("<c-s>", function()
      vim.lsp.buf.signature_help({ border = vim.g.ui_border })
    end, "LSP: Signature Help", { "i", "s" }, opts)
    map("gK", function()
      vim.lsp.buf.signature_help({ border = vim.g.ui_border })
    end, "LSP: Signature Help", "n", opts)
    map("K", function()
      vim.lsp.buf.hover({ border = vim.g.ui_border })
    end, "LSP: Hover", "n", opts)
    map("gd", function()
      vim.lsp.buf.definition()
    end, "LSP: Goto Definition", "n", opts)
    map("grt", function()
      vim.lsp.buf.type_definition()
    end, "LSP: Goto Type Definition", "n", opts)
    map("grd", function()
      vim.lsp.buf.declaration()
    end, "Goto Declaration", "n", opts)
    map("gq", function()
      vim.lsp.buf.format({ async = true })
    end, "LSP: Format", "n", opts)
    map("grc", function()
      vim.lsp.codelens.run()
    end, "Run Codelens", "n", opts)
    map("grC", function()
      vim.lsp.codelens.refresh()
    end, "Refresh and Display Codelens", "n", opts)

    -- fzf-lua
    local fzf = require("fzf-lua")
    map("grr", function()
      fzf.lsp_references({ ignore_current_line = true })
    end, "References", "n", opts)
    map("gri", function()
      fzf.lsp_implementations()
    end, "Implementation", "n", opts)
    map("gra", function()
      fzf.lsp_code_actions({
        winopts = {
          relative = "cursor",
          width = 0.6,
          height = 0.6,
          row = 1,
          preview = { vertical = "up:70%" },
        },
      })
    end, "Code Action", "n", opts)
    map("g0", function()
      fzf.lsp_document_symbols()
    end, "LSP: Document Symbol", "n", opts)
    map("gd", function()
      fzf.lsp_definitions({ jump1 = true })
    end, "LSP: Goto Definition", "n", opts)
    map("grt", function()
      fzf.lsp_typedefs()
    end, "Goto Type Definition", "n", opts)
    map("grd", function()
      fzf.lsp_declarations()
    end, "Goto Declaration", "n", opts)
    map("grn", function()
      return ":IncRename " .. vim.fn.expand("<cword>")
    end, "Incremental Rename", "n", { buffer = event.buf, desc = "Incremental Rename", expr = true })

    -- lsp_signature
    if Devastion.lazy.has("lsp_signature.nvim") then
      map("<c-s>", function()
        require("lsp_signature").toggle_float_win()
      end, "LSP: Signature Help", { "i", "s", "n" }, opts)
    end
  end,
})
