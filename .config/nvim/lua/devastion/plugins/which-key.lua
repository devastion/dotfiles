vim.pack.add({ "https://github.com/folke/which-key.nvim" }, { confirm = false })

require("which-key").setup({
  preset = "modern",
  delay = 0,
  spec = {
    { "<leader>f", group = "+[Find]" },
    { "<leader>c", group = "+[Code]", mode = { "n", "v" } },
    { "<leader>s", group = "+[Search]", mode = { "n", "v" } },
    { "<leader>g", group = "+[Git]", mode = { "n", "v" } },
    { "<leader>T", group = "+[Toggles]", mode = { "n", "v" } },
    { "<leader><tab>", group = "+[Tabs]" },
    { "gr", group = "+[LSP]" },
    { "gc", group = "+[Comment]" },
    { "[", group = "+[Prev]", mode = { "n", "v", "o" } },
    { "]", group = "+[Next]", mode = { "n", "v", "o" } },
    { "g", group = "+[Goto]" },
    { "z", group = "+[Fold]" },
    { "s", group = "+[Surround/Operators]" },
    { "<leader>b", group = "+[Buffers]", expand = function() return require("which-key.extras").expand.buf() end },
    { "<C-w>", group = "+[Windows]", expand = function() return require("which-key.extras").expand.win() end },
  },
  icons = {
    mappings = true,
    keys = {
      Space = "Space",
      Esc = "Esc",
      BS = "Backspace",
      C = "Ctrl-",
    },
  },
  triggers = {
    { "<auto>", mode = "nixsotc" },
    { "s", mode = { "n", "v" } },
  },
  sort = { "order", "group", "alphanum" },
})
