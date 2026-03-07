local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "chrisgrieser/nvim-scissors",
    data = {
      config = function()
        require("scissors").setup({
          snippetDir = vim.fn.stdpath("config") .. "/snippets",
          jsonFormatter = "jq",
        })

        map("<leader>cS", function()
          require("scissors").editSnippet()
        end, "Snippet: Edit")

        map("<leader>cs", function()
          require("scissors").addNewSnippet()
        end, "Snippet: Add", { "n", "x" })
      end,
    },
  },
})
