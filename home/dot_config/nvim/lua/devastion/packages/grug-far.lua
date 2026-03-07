local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "magicduck/grug-far.nvim",
    data = {
      config = function()
        local grug_far = require("grug-far")

        grug_far.setup({
          headerMaxWidth = 80,
        })

        map("<leader>cR", function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end, "Search and Replace <cword>")

        map("<leader>cR", function()
          require("grug-far").with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
        end, "Search and Replace", "v")
      end,
    },
  },
})
