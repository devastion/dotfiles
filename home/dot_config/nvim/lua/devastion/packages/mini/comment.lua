require("devastion.utils.pkg").add({
  {
    src = "joosepalviste/nvim-ts-context-commentstring",
    data = {
      config = function()
        require("ts_context_commentstring").setup({
          enable_autocmd = false,
        })
      end,
    },
  },
  {
    src = "nvim-mini/mini.comment",
    data = {
      config = function()
        require("mini.comment").setup({
          options = {
            custom_commentstring = function()
              return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
            end,
          },
        })
      end,
    },
  },
})
