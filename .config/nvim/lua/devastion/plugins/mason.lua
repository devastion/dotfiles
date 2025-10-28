---@type LazySpec
return {
  "mason-org/mason.nvim",
  cmd = { "Mason", "MasonUpdate" },
  keys = {
    {
      "<leader>cm",
      function()
        require("mason.api.command").Mason()
      end,
      desc = "Mason",
    },
  },
  build = function()
    require("mason.api.command").MasonUpdate()
  end,
  opts = {
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
      border = vim.g.ui_border,
      width = 0.8,
      height = 0.8,
    },
  },
  config = function(_, opts)
    require("mason").setup(opts)
    require("devastion.utils").mason_install(vim.g.mason_ensure_installed)
  end,
  init = function()
    vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, "/") .. ":" .. vim.env.PATH
  end,
}
