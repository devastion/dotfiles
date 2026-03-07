local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "danymat/neogen",
    data = {
      config = function()
        require("neogen").setup({
          snippet_engine = "nvim",
          languages = {
            lua = { template = { annotation_convention = "emmylua" } },
            python = { template = { annotation_convention = "numpydoc" } },
          },
        })

        map("<leader>cn", function()
          require("neogen").generate()
        end, "Neogen")
      end,
    },
  },
})
