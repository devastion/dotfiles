---@type LazySpec
return {
  "NMAC427/guess-indent.nvim",
  opts = {},
  keys = {
    { "<leader>PG", function() vim.cmd("GuessIndent") end, desc = "Guess Indent" },
  },
}
