require("devastion.utils.pkg").add({
  {
    src = "arnamak/stay-centered.nvim",
    data = {
      event = { "BufReadPost", "BufWritePost", "BufNewFile" },
      config = function()
        require("stay-centered").setup({
          skip_filetypes = {
            "minifiles",
            "sidekick_terminal",
          },
        })
      end,
    },
  },
})
