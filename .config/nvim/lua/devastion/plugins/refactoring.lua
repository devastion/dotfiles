---@type LazySpec
return {
  "ThePrimeagen/refactoring.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "main",
    },
  },
  keys = function()
    require("which-key").add({ "<leader>r", group = "+[Refactor]", mode = { "n", "x" } })
    require("which-key").add({ "<leader>rb", group = "+[Block]", mode = { "n", "x" } })
    return {
      {
        "<leader>rr",
        function()
          require("refactoring").select_refactor()
        end,
        mode = { "n", "x" },
        desc = "Select Refactor",
      },
      {
        "<leader>re",
        function()
          return require("refactoring").refactor("Extract Function")
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Extract Function",
      },
      {
        "<leader>rf",
        function()
          return require("refactoring").refactor("Extract Function To File")
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Extract Function To File",
      },
      {
        "<leader>rv",
        function()
          return require("refactoring").refactor("Extract Variable")
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Extract Variable",
      },
      {
        "<leader>rI",
        function()
          return require("refactoring").refactor("Inline Function")
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Inline Function",
      },
      {
        "<leader>ri",
        function()
          return require("refactoring").refactor("Inline Variable")
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Inline Variable",
      },
      {
        "<leader>rbb",
        function()
          return require("refactoring").refactor("Extract Block")
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Extract Block",
      },
      {
        "<leader>rbf",
        function()
          return require("refactoring").refactor("Extract Block To File")
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Extract Block To File",
      },
      {
        "<leader>rp",
        function()
          require("refactoring").debug.print_var()
        end,
        mode = { "x", "n" },
        desc = "Print var",
      },
      {
        "<leader>rP",
        function()
          require("refactoring").debug.printf({ below = false })
        end,
        mode = "n",
        desc = "Print",
      },
      {
        "<leader>rc",
        function()
          require("refactoring").debug.cleanup({})
        end,
        mode = "n",
        desc = "Cleanup",
      },
    }
  end,
}
