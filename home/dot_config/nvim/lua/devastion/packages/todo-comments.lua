local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "folke/todo-comments.nvim",
    data = {
      config = function()
        require("todo-comments").setup()

        map("]t", function()
          require("todo-comments").jump_next()
        end, "Next ToDo Comment")
        map("[t", function()
          require("todo-comments").jump_prev()
        end, "Prev ToDo Comment")

        map("<leader>st", function()
          require("todo-comments.fzf").todo()
        end, "Todo")
        map("<leader>sT", function()
          require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } })
        end, "Todo/Fix/Fixme")
      end,
    },
  },
})
