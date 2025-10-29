---@type LazySpec
return {
  "mason-org/mason.nvim",
  cmd = { "Mason", "MasonUpdate" },
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
      check_outdated_packages_on_open = false,
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
      "ansible-lint",
      "basedpyright",
      "bash-language-server",
      "black",
      "blade-formatter",
      "clangd",
      "cspell",
      "cspell-lsp",
      "css-lsp",
      "debugpy",
      "docker-language-server",
      "dotenv-linter",
      "eslint-lsp",
      "graphql-language-service-cli",
      "hadolint",
      "html-lsp",
      "intelephense",
      "js-debug-adapter",
      "json-lsp",
      "lua-language-server",
      "markdown-toc",
      "markdownlint-cli2",
      "marksman",
      "php-cs-fixer",
      "php-debug-adapter",
      "phpcs",
      "pint",
      "prettier",
      "ruff",
      "shellcheck",
      "shfmt",
      "sqlfluff",
      "stylua",
      "taplo",
      "typescript-language-server",
      { "vue-language-server", version = "3.0.8" },
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
