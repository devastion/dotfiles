require("devastion.utils.pkg").add({
  {
    src = "meanderingprogrammer/render-markdown.nvim",
    data = {
      event = { "FileType" },
      pattern = { "markdown", "norg", "rmd", "org" },
      config = function()
        require("render-markdown").setup({
          enabled = false,
          completions = {
            lsp = {
              enabled = true,
            },
          },
        })
      end,
    },
  },
})
