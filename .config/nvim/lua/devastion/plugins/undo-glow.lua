---@type LazySpec
return {
  "y3owk1n/undo-glow.nvim",
  lazy = true,
  opts = {},
  keys = {
    {
      "u",
      function()
        require("undo-glow").undo()
      end,
      mode = "n",
      desc = "Undo with highlight",
      noremap = true,
    },
  },
}
