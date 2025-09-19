if vim.g.tabline_enabled then
  vim.pack.add({ "https://github.com/tiagovla/scope.nvim" }, { confirm = false })

  require("scope").setup()
end
