local utils = require("devastion.utils")
local map = vim.g.remap
vim.lsp.enable(utils.get_lsp_configs())

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
  callback = function(event)
    local client_id = vim.tbl_get(event, "data", "client_id")
    local client = vim.lsp.get_client_by_id(client_id)

    if client ~= nil then
      if client:supports_method(vim.lsp.protocol.Methods.textDocument_foldingRange) then
        vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
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
    map("<C-k>", function()
      vim.lsp.buf.signature_help({ border = vim.g.ui_border })
    end, "LSP: Signature Help", { "i", "s" }, opts)
    map("<C-s>", function()
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
  end,
})

---@type LazySpec
return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = {
      {
        "<leader>cm",
        function()
          require("mason.api.command").Mason()
        end,
        desc = "Mason",
      },
    },
    build = function()
      require("mason.api.command").MasonUpdate()
    end,
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = vim.g.ui_border,
        width = 0.8,
        height = 0.8,
      },
      ensure_installed = {
        "actionlint",
        "ansible-language-server",
        "basedpyright",
        "bash-language-server",
        "black",
        "blade-formatter",
        "clangd",
        "cspell",
        "css-lsp",
        "debugpy",
        "docker-language-server",
        "dotenv-linter",
        "eslint-lsp",
        "graphql-language-service-cli",
        "hadolint",
        "html-lsp",
        "intelephense",
        "json-lsp",
        "lua-language-server",
        "marksman",
        "php-cs-fixer",
        "phpcs",
        "pint",
        "prettier",
        "ruff",
        "shellcheck",
        "shfmt",
        "stylua",
        "taplo",
        "typescript-language-server",
        "vue-language-server",
        "yaml-language-server",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      utils.mason_install(opts.ensure_installed)
    end,
    init = function()
      vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, "/") .. ":" .. vim.env.PATH
    end,
  },
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {},
  },
  {
    "artemave/workspace-diagnostics.nvim",
    lazy = true,
    keys = {
      {
        "<leader>cx",
        function()
          for _, client in ipairs(vim.lsp.get_clients()) do
            require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
          end
        end,
        desc = "Workspace Diagnostics",
      },
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    ft = "python",
    keys = {
      { "<leader>cv", "<CMD>:VenvSelect<CR>", desc = "Select VirtualEnv", ft = "python" },
    },
    opts = {
      options = {
        notify_user_on_venv_activation = true,
      },
    },
  },
  {
    "vuki656/package-info.nvim",
    event = { "BufReadPost package.json" },
    opts = {},
    keys = function()
      require("which-key").add({ "<leader>n", group = "+[Package Info]" })
      return {
        {
          "<leader>ns",
          function()
            require("package-info").show()
          end,
          mode = "n",
          desc = "Show Package Info",
        },
        {
          "<leader>nh",
          function()
            require("package-info").hide()
          end,
          mode = "n",
          desc = "Hide Package Info",
        },
        {
          "<leader>nt",
          function()
            require("package-info").toggle()
          end,
          mode = "n",
          desc = "Toggle Package Info",
        },
        {
          "<leader>nu",
          function()
            require("package-info").update()
          end,
          mode = "n",
          desc = "Update Package",
        },
        {
          "<leader>nd",
          function()
            require("package-info").delete()
          end,
          mode = "n",
          desc = "Delete Package",
        },
        {
          "<leader>ni",
          function()
            require("package-info").install()
          end,
          mode = "n",
          desc = "Install Package",
        },
        {
          "<leader>nc",
          function()
            require("package-info").change_version()
          end,
          mode = "n",
          desc = "Change Package Version",
        },
      }
    end,
  },
}
