local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "mrjones2014/smart-splits.nvim",
    data = {
      config = function()
        map("<c-left>", function()
          require("smart-splits").resize_left()
        end, "Resize split left (smart-splits)", "n")

        map("<c-down>", function()
          require("smart-splits").resize_down()
        end, "Resize split down (smart-splits)", "n")

        map("<c-up>", function()
          require("smart-splits").resize_up()
        end, "Resize split up (smart-splits)", "n")

        map("<c-right>", function()
          require("smart-splits").resize_right()
        end, "Resize split right (smart-splits)", "n")

        map("<c-h>", function()
          require("smart-splits").move_cursor_left()
        end, "Move cursor left split (smart-splits)", "n")

        map("<c-j>", function()
          require("smart-splits").move_cursor_down()
        end, "Move cursor down split (smart-splits)", "n")

        map("<c-k>", function()
          require("smart-splits").move_cursor_up()
        end, "Move cursor up split (smart-splits)", "n")

        map("<c-l>", function()
          require("smart-splits").move_cursor_right()
        end, "Move cursor right split (smart-splits)", "n")

        map("<C-\\>", function()
          if vim.env.TMUX then
            vim.fn.jobstart({ "tmux", "selectp", "-l" })
          else
            vim.notify("Not inside TMux", vim.log.levels.WARN)
          end
        end, "Move cursor to previous split (smart-splits)", "n")
      end,
    },
  },
})
