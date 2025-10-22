---@type LazySpec
return {
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
    require("devastion.utils").mason_install(opts.ensure_installed)
  end,
  init = function()
    vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, "/") .. ":" .. vim.env.PATH
  end,
}
