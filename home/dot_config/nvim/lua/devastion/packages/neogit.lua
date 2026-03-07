local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "NeogitOrg/neogit",
    data = {
      config = function()
        require("neogit").setup({})
        map("<leader>gN", function()
          require("neogit").open()
        end, "Neogit")
      end,
    },
  },
})
