local lsp_utils = require("devastion.utils.lsp")
local lsp_configs = lsp_utils.lsp_configs()
vim.lsp.enable(lsp_configs)

local tailwind_config_exists = lsp_utils.tailwind_config_exists()

if not tailwind_config_exists then
  vim.lsp.enable("tailwindcss-language-server", false)
end

local signs = { ERROR = "✘", WARN = "▲", HINT = "⚑", INFO = "»" }
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = signs.ERROR,
      [vim.diagnostic.severity.WARN] = signs.WARN,
      [vim.diagnostic.severity.HINT] = signs.HINT,
      [vim.diagnostic.severity.INFO] = signs.INFO,
    },
  },
  float = {
    source = false,
    border = "single",
    suffix = "",
    prefix = "",
    format = function(diagnostic)
      if not diagnostic.code and not diagnostic.user_data then
        return string.format("%s (%s)", diagnostic.message, diagnostic.source)
      end

      return string.format(
        "%s (%s) [%s]",
        diagnostic.message,
        diagnostic.source,
        diagnostic.code or diagnostic.user_data.lsp.code
      )
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

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
  desc = "LSP Attach",
  callback = function(event)
    local client_id = vim.tbl_get(event, "data", "client_id")
    local client = vim.lsp.get_client_by_id(client_id)
    local lsp_methods = vim.lsp.protocol.Methods

    vim.lsp.completion.enable(false, client_id, event.buf, { autotrigger = false })

    local function lsp_keymap(method, lhs, rhs, desc, mode, opts)
      mode = mode or "n"
      opts = opts or {}
      opts.desc = desc
      opts.buffer = event.buf

      if client and client:supports_method(method) then
        vim.keymap.set(mode, lhs, rhs, opts)
      end
    end

    -- Use ESLint as formatter
    if client ~= nil then
      if client.name == "eslint-lsp" then
        client.server_capabilities.documentFormattingProvider = true
      elseif client.name == "vtsls" or client.name == "vue-language-server" then
        client.server_capabilities.documentFormattingProvider = false
      end
    end

    lsp_keymap(
      lsp_methods.textDocument_references,
      "grr",
      function() require("fzf-lua").lsp_references({}) end,
      "References"
    )
    lsp_keymap(
      lsp_methods.textDocument_implementation,
      "gri",
      function() require("fzf-lua").lsp_implementations({}) end,
      "Implementation"
    )
    lsp_keymap(
      lsp_methods.textDocument_codeAction,
      "gra",
      function()
        require("fzf-lua").lsp_code_actions({
          winopts = {
            relative = "cursor",
            width = 0.6,
            height = 0.6,
            row = 1,
            preview = { vertical = "up:70%" },
          },
        })
      end,
      "Code Action"
    )
    lsp_keymap(
      lsp_methods.textDocument_documentSymbol,
      "gO",
      function() require("fzf-lua").lsp_document_symbols({}) end,
      "LSP: Document Symbol"
    )

    vim.keymap.set(
      { "i", "s" },
      "<C-s>",
      function() vim.lsp.buf.signature_help({ border = "single" }) end,
      { buffer = event.buf }
    )
    vim.keymap.set(
      { "n", "x" },
      "gq",
      function() vim.lsp.buf.format({ async = true }) end,
      { buffer = event.buf, desc = "LSP: Format" }
    )
    vim.keymap.set(
      "n",
      "K",
      function() vim.lsp.buf.hover({ border = "single" }) end,
      { buffer = event.buf, desc = "LSP: Hover" }
    )
    vim.keymap.set(
      "n",
      "gK",
      function() vim.lsp.buf.signature_help({ border = "single" }) end,
      { buffer = event.buf, desc = "LSP: Signature Help" }
    )
    vim.keymap.set(
      "n",
      "gh",
      function() vim.lsp.buf.hover({ border = "single" }) end,
      { buffer = event.buf, desc = "LSP: Hover" }
    )
    lsp_keymap(
      lsp_methods.textDocument_definition,
      "gd",
      function() require("fzf-lua").lsp_definitions({}) end,
      "LSP: Definition"
    )
    lsp_keymap(
      lsp_methods.textDocument_typeDefinition,
      "grt",
      function() require("fzf-lua").lsp_typedefs({}) end,
      "Type Definition"
    )
    lsp_keymap(
      lsp_methods.textDocument_declaration,
      "grd",
      function() require("fzf-lua").lsp_declarations({}) end,
      "Declaration"
    )
    vim.keymap.set(
      "n",
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
      { buffer = event.buf, desc = "Source Action" }
    )
    vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
    vim.keymap.set("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Open Diagnostics List" })

    if client then
      if client:supports_method(lsp_methods.textDocument_rename) then
        vim.keymap.set(
          "n",
          "grn",
          function() return ":IncRename " .. vim.fn.expand("<cword>") end,
          { buffer = event.buf, desc = "Incremental Rename", expr = true }
        )
      end

      -- if client:supports_method(lsp_methods.textDocument_foldingRange) then
      --   vim.o.foldmethod = "expr"
      --   vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
      -- end
    end
  end,
})
