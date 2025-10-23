---@type LazySpec
return {
  "mrjones2014/smart-splits.nvim",
  keys = {
    {
      "<c-left>",
      function()
        require("smart-splits").resize_left()
      end,
      mode = "n",
      desc = "Resize split left (smart-splits)",
    },
    {
      "<c-down>",
      function()
        require("smart-splits").resize_down()
      end,
      mode = "n",
      desc = "Resize split down (smart-splits)",
    },
    {
      "<c-up>",
      function()
        require("smart-splits").resize_up()
      end,
      mode = "n",
      desc = "Resize split up (smart-splits)",
    },
    {
      "<c-right>",
      function()
        require("smart-splits").resize_right()
      end,
      mode = "n",
      desc = "Resize split right (smart-splits)",
    },
    {
      "<c-h>",
      function()
        require("smart-splits").move_cursor_left()
      end,
      mode = "n",
      desc = "Move cursor left split (smart-splits)",
    },
    {
      "<c-j>",
      function()
        require("smart-splits").move_cursor_down()
      end,
      mode = "n",
      desc = "Move cursor down split (smart-splits)",
    },
    {
      "<c-k>",
      function()
        require("smart-splits").move_cursor_up()
      end,
      mode = "n",
      desc = "Move cursor up split (smart-splits)",
    },
    {
      "<c-l>",
      function()
        require("smart-splits").move_cursor_right()
      end,
      mode = "n",
      desc = "Move cursor right split (smart-splits)",
    },
    {
      "<C-\\>",
      function()
        if vim.env.TMUX then
          vim.fn.jobstart({ "tmux", "selectp", "-l" })
        else
          vim.notify("Not inside TMux", vim.log.levels.WARN)
        end
      end,
      mode = "n",
      desc = "Move cursor to previous split (smart-splits)",
    },
  },
}
