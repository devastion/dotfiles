require("devastion.utils.pkg").add({
  {
    src = "samjwill/nvim-unception",
    data = {
      init = function()
        vim.g.unception_block_while_host_edits = true
      end,
    },
  },
  {
    src = "rawnly/gist.nvim",
    data = {
      config = function()
        require("gist").setup({})
      end,
    },
  },
})
