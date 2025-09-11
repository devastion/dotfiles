MiniDeps.later(function()
  MiniDeps.add("folke/todo-comments.nvim")

  require("todo-comments").setup()

  vim.keymap.set("n", "<leader>st", function() require("todo-comments.fzf").todo() end, { desc = "Todo" })
  vim.keymap.set(
    "n",
    "<leader>sT",
    function() require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } }) end,
    { desc = "Todo/Fix/Fixme" }
  )
  vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next Todo" })
  vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Prev Todo" })
end)
