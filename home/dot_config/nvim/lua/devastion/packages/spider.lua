local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "chrisgrieser/nvim-spider",
    data = {
      event = { "BufReadPost", "BufWritePost", "BufNewFile" },
      config = function()
        require("spider").setup({
          skipInsignificantPunctuation = false,
          consistentOperatorPending = true,
          subwordMovement = true,
          customPatterns = {},
        })

        map("w", function()
          require("spider").motion("w")
        end, nil, { "n", "o", "x" })
        map("e", function()
          require("spider").motion("e")
        end, nil, { "n", "o", "x" })
        map("b", function()
          require("spider").motion("b")
        end, nil, { "n", "o", "x" })
        map("ge", function()
          require("spider").motion("ge")
        end, nil, { "n", "o", "x" })
        map("cw", "c<cmd>lua require('spider').motion('e')<cr>")
        map("<C-f>", "<Esc>l<cmd>lua require('spider').motion('w')<cr>i", nil, "i")
        map("<C-b>", "<Esc>l<cmd>lua require('spider').motion('b')<cr>i", nil, "i")
      end,
    },
  },
})
