---@type LazySpec
return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  lazy = true,
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format()
      end,
      mode = { "n", "x" },
      desc = "Format",
    },
    {
      "<leader>cF",
      function()
        require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
      end,
      mode = { "n", "v" },
      desc = "Format Injected Langs",
    },
  },
  opts = function()
    return {
      default_format_opts = {
        timeout_ms = 3000,
        async = true,
        quiet = false,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        bash = { "shfmt" },
        sh = { "shfmt" },
        blade = { "blade-formatter" },
        php = vim.g.is_laravel_project and { "pint" } or { "php_cs_fixer" },
        graphql = { "prettier" },
        python = { "black" },
      },
      stop_after_first = true,
      formatters = {
        injected = { options = { ignore_errors = true } },
      },
      format_on_save = function(bufnr)
        if vim.g.autoformat_enabled or vim.b[bufnr].autoformat_enabled then
          return { timeout_ms = 3000, lsp_format = "fallback" }
        end
      end,
    }
  end,
}
