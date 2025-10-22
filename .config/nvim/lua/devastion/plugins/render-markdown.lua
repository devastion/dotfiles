---@type LazySpec
return {
  "meanderingprogrammer/render-markdown.nvim",
  ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
  opts = {},
  keys = {
    { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Render Markdown", ft = "markdown" },
  },
}
