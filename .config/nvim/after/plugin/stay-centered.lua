MiniDeps.later(function()
  MiniDeps.add({ source = "arnamak/stay-centered.nvim" })

  require("stay-centered").setup({ skip_filetypes = { "minifiles" } })
end)
