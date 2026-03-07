local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "sengoku11/commitpad.nvim",
    data = {
      config = function()
        require("commitpad").setup({
          footer = true,
        })

        map("<leader>gc", function()
          require("commitpad.ui").open()
        end, "CommitPad")
        map("<leader>gC", function()
          require("commitpad.ui").amend()
        end, "CommitPad Amend")
      end,
    },
  },
})
