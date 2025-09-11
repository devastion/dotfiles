MiniDeps.later(function()
  MiniDeps.add({ source = "brenoprata10/nvim-highlight-colors" })

  require("nvim-highlight-colors").setup({
    render = "virtual",
    enable_named_colors = false,
    enable_tailwind = true,
    virtual_symbol = "󱓻",
  })
end)
