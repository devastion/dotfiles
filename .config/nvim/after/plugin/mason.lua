MiniDeps.later(function()
  MiniDeps.add({ source = "williamboman/mason.nvim" })

  require("mason").setup({
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
  })

  vim.keymap.set("n", "<leader>cm", function() require("mason.api.command").Mason() end, { desc = "Mason" })
end)
