vim.pack.add({
  { src = "https://github.com/arnamak/stay-centered.nvim" },
  { src = "https://github.com/b0o/schemastore.nvim" },
  { src = "https://github.com/smjonas/inc-rename.nvim" },
  { src = "https://github.com/brenoprata10/nvim-highlight-colors" },
  { src = "https://github.com/nmac427/guess-indent.nvim" },
}, { confirm = false })

require("stay-centered").setup({ skip_filetypes = { "minifiles" } })
require("inc_rename").setup({})
require("nvim-highlight-colors").setup({
  render = "virtual",
  enable_named_colors = false,
  enable_tailwind = true,
  virtual_symbol = "󱓻",
})
require("guess-indent").setup({})
