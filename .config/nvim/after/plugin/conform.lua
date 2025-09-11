MiniDeps.now(function()
  MiniDeps.add({ source = "stevearc/conform.nvim" })

  require("conform").setup({
    default_format_opts = {
      timeout_ms = 3000,
      async = true,
      quiet = false,
      lsp_format = "fallback",
    },
    formatters_by_ft = {},
    stop_after_first = true,
    formatters = {
      injected = { options = { ignore_errors = true } },
    },
    format_on_save = function(bufnr)
      if vim.g.autoformat_enabled or vim.b[bufnr].autoformat_enabled then
        return { timeout_ms = 3000, lsp_format = "fallback" }
      end
    end,
  })

  vim.keymap.set({ "n", "x" }, "<leader>cf", function() require("conform").format() end, { desc = "Format" })
end)
