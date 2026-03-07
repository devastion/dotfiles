local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "iamcco/markdown-preview.nvim",
    data = {
      event = { "FileType" },
      pattern = { "markdown", "norg", "rmd", "org" },
      task = function(p)
        vim.system({ "bash", "-c", "app/install.sh" }, { cwd = p.spec.path })
      end,
      config = function()
        map("<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", "Markdown Preview", "n", { buffer = true })
      end,
    },
  },
})
