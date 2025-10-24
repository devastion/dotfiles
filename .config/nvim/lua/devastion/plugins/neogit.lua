---@type LazySpec
return {
  "NeogitOrg/neogit",
  lazy = true,
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
