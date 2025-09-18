vim.pack.add({ "https://github.com/brenoprata10/nvim-highlight-colors" }, { confirm = false })

require("nvim-highlight-colors").setup({
  render = "virtual",
  enable_named_colors = false,
  enable_tailwind = true,
  virtual_symbol = "󱓻",
})
