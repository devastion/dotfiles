require("devastion.utils.pkg").add({
  {
    src = "pwntester/octo.nvim",
    data = {
      config = function()
        require("octo").setup({
          picker = "fzf-lua",
          enable_builtin = true,
        })

        require("devastion.utils").map("<leader>gO", function()
          require("octo.commands").actions()
        end, "Octo")
      end,
    },
  },
})
