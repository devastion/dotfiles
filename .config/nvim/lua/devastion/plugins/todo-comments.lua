---@type LazySpec
return {
  "folke/todo-comments.nvim",
  cmd = { "TodoFzfLua" },
  lazy = true,
  opts = {},
  keys = {
    {
      "]t",
      function()
        require("todo-comments").jump_next()
      end,
      desc = "Next Todo Comment",
    },
    {
      "[t",
      function()
        require("todo-comments").jump_prev()
      end,
      desc = "Previous Todo Comment",
    },
    {
      "<leader>st",
      function()
        require("todo-comments.fzf").todo()
      end,
      desc = "Todo",
    },
    {
      "<leader>sT",
      function()
        require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } })
      end,
      desc = "Todo/Fix/Fixme",
    },
  },
}
