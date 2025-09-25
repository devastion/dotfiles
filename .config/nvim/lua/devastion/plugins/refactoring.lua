vim.pack.add({ "https://github.com/ThePrimeagen/refactoring.nvim" }, { confirm = false })

require("refactoring").setup({})

require("which-key").add({ "<leader>r", group = "+[Refactor]", mode = { "n", "x" } })
require("which-key").add({ "<leader>rb", group = "+[Block]", mode = { "n", "x" } })

vim.keymap.set(
  { "n", "x" },
  "<leader>rr",
  function() require("refactoring").select_refactor() end,
  { desc = "Select Refactor" }
)
vim.keymap.set(
  { "n", "x" },
  "<leader>re",
  function() return require("refactoring").refactor("Extract Function") end,
  { expr = true, desc = "Extract Function" }
)
vim.keymap.set(
  { "n", "x" },
  "<leader>rf",
  function() return require("refactoring").refactor("Extract Function To File") end,
  { expr = true, desc = "Extract Function To File" }
)
vim.keymap.set(
  { "n", "x" },
  "<leader>rv",
  function() return require("refactoring").refactor("Extract Variable") end,
  { expr = true, desc = "Extract Variable" }
)
vim.keymap.set(
  { "n", "x" },
  "<leader>rI",
  function() return require("refactoring").refactor("Inline Function") end,
  { expr = true, desc = "Inline Function" }
)
vim.keymap.set(
  { "n", "x" },
  "<leader>ri",
  function() return require("refactoring").refactor("Inline Variable") end,
  { expr = true, desc = "Inline Variable" }
)
vim.keymap.set(
  { "n", "x" },
  "<leader>rbb",
  function() return require("refactoring").refactor("Extract Block") end,
  { expr = true, desc = "Extract Block" }
)
vim.keymap.set(
  { "n", "x" },
  "<leader>rbf",
  function() return require("refactoring").refactor("Extract Block To File") end,
  { expr = true, desc = "Extract Block To File" }
)

vim.keymap.set(
  { "x", "n" },
  "<leader>rp",
  function() require("refactoring").debug.print_var() end,
  { desc = "Print var" }
)
vim.keymap.set(
  "n",
  "<leader>rP",
  function() require("refactoring").debug.printf({ below = false }) end,
  { desc = "Print" }
)
vim.keymap.set("n", "<leader>rc", function() require("refactoring").debug.cleanup({}) end, { desc = "Cleanup" })
