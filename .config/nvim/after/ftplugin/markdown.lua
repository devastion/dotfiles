MiniDeps.later(function()
  local build = function() vim.fn["mkdp#util#install"]() end
  MiniDeps.add({
    source = "iamcco/markdown-preview.nvim",
    hooks = {
      post_install = function() MiniDeps.later(build) end,
      post_checkout = build,
    },
  })

  MiniDeps.add({ source = "meanderingprogrammer/render-markdown.nvim" })

  vim.keymap.set("n", "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", { buffer = true, desc = "Markdown Preview" })
end)
