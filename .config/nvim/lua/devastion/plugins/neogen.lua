vim.pack.add({ "https://github.com/danymat/neogen" }, { confirm = false })

require("neogen").setup({
  snippet_engine = "nvim",
  languages = {
    lua = { template = { annotation_convention = "emmylua" } },
    python = { template = { annotation_convention = "numpydoc" } },
  },
})

vim.keymap.set(
  "n",
  "<leader>cn",
  function() require("neogen").generate() end,
  { desc = "Generate Annotations (Neogen)" }
)
