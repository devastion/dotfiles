---@type LazySpec
return {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  lazy = false,
  opts = {
    enabled = true,
  },
  keys = {
    {
      "<leader>uH",
      function()
        require("hardtime").toggle()
        vim.notify("Hardtime toggled")
      end,
      desc = "Toggle Hardtime",
    },
  },
}
