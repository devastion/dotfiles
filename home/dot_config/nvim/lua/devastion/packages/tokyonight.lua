require("devastion.utils.pkg").add({
  {
    src = "folke/tokyonight.nvim",
    data = {
      config = function()
        require("tokyonight").setup({
          style = "night",
        })

        vim.api.nvim_cmd({
          cmd = "colorscheme",
          args = { "tokyonight" },
        }, {})
      end,
    },
  },
})
