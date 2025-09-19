vim.pack.add({ "https://github.com/smjonas/live-command.nvim" }, { confirm = false })

require("live-command").setup({
  enable_highlighting = true,
  inline_highlighting = true,
  commands = {
    Norm = { cmd = "norm" },
  },
})

vim.cmd("cnoreabbrev norm Norm")
