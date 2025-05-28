---@type LazySpec
return {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    enabled = false,
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
