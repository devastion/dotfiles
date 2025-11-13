---@type LazySpec
return {
  "tttol/md-outline.nvim",
  ft = { "markdown" },
  keys = {
    {
      "<localleader>o",
      function()
        require("md-outline").show()
      end,
      desc = "Show Outline",
      ft = "markdown",
    },
    {
      "<localleader>O",
      function()
        require("md-outline").close()
      end,
      desc = "Close Outline",
      ft = "markdown",
    },
  },
}
