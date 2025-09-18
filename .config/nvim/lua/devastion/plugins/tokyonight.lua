vim.pack.add({ "https://github.com/folke/tokyonight.nvim" }, { confirm = false })

require("tokyonight").setup({ style = "night" })

vim.api.nvim_cmd({
  cmd = "colorscheme",
  args = { "tokyonight-night" },
}, {})
