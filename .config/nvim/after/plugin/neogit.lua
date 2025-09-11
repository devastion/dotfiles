MiniDeps.later(function()
  MiniDeps.add({
    source = "neogitorg/neogit",
    depends = { "nvim-lua/plenary.nvim", "ibhagwan/fzf-lua" },
  })

  require("neogit").setup({})

  vim.keymap.set("n", "<leader>gN", function() require("neogit").open() end, { desc = "Neogit" })
end)
