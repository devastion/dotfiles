---@type LazySpec
return {
  "meanderingprogrammer/render-markdown.nvim",
  ft = { "markdown", "norg", "rmd", "org" },
  opts = {
    completions = {
      lsp = {
        enabled = true,
      },
    },
  },
  keys = {
    {
      "<leader>um",
      function()
        Snacks.toggle({
          name = "Render Markdown",
          get = require("render-markdown").get,
          set = require("render-markdown").set,
        }):map("<leader>um")
      end,
      desc = "Toggle Render Markdown",
      ft = "markdown",
    },
  },
}
