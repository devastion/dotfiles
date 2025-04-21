---@type LazySpec
return {
  "NeogitOrg/neogit",
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
  },
  opts = {},
  keys = {
    {
      "<leader>gN",
      function() require("neogit").open() end,
      desc = "Neogit",
    },
  },
}
