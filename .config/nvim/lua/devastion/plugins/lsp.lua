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
        border = "single",
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
      local utils = require("devastion.utils")
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
    dependencies = { "muniftanjim/nui.nvim" },
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
