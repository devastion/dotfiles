vim.pack.add({ "https://github.com/kevinhwang91/nvim-bqf" }, { confirm = false })

require("bqf").setup({
  auto_resize_height = false,
  preview = {
    auto_preview = false,
  },
})
