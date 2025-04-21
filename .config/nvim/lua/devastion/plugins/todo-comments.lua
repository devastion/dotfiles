---@type LazySpec
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  opts = {},
  keys = {
    { "<leader>st", function() require("todo-comments.fzf").todo() end, desc = "Todo" },
    {
      "<leader>sT",
      function() require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } }) end,
      desc = "Todo/Fix/Fixme",
    },
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev Todo" },
  },
}
