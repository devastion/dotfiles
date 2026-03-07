require("devastion.utils.pkg").add({
  {
    src = "nmac427/guess-indent.nvim",
    data = {
      event = { "BufReadPost" },
      config = function()
        require("guess-indent").setup({})
      end,
    },
  },
})
