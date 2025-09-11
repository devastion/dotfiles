local build = function() vim.fn["mkdp#util#install"]() end

vim.pack.add({
  { src = "https://github.com/iamcco/markdown-preview.nvim" },
  { src = "https://github.com/meanderingprogrammer/render-markdown.nvim" },
}, { confirm = false })

build()

vim.keymap.set("n", "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", { buffer = true, desc = "Markdown Preview" })
