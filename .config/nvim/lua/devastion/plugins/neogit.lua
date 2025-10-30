---@type LazySpec
return {
  "NeogitOrg/neogit",
  lazy = true,
  dependencies = {
    "ibhagwan/fzf-lua",
  },
  cmd = { "Neogit" },
  opts = {},
  keys = {
    {
      "<leader>gN",
      function()
        require("neogit").open()
      end,
      desc = "Neogit",
    },
  },
}
