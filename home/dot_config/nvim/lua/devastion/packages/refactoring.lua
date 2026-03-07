local map = require("devastion.utils").map
local wk = require("which-key")

require("devastion.utils.pkg").add({
  {
    src = "nvim-treesitter/nvim-treesitter",
    version = "main",
  },
  "theprimeagen/refactoring.nvim",
})

wk.add({
  mode = { "n", "x" },
  { "<leader>r", group = "+[Refactor]" },
  { "<leader>rb", group = "+[Block]" },
})

map("<leader>rr", function()
  require("refactoring").select_refactor()
end, "Select Refactor", { "n", "x" })

map("<leader>re", function()
  return require("refactoring").refactor("Extract Function")
end, "Extract Function", { "n", "x" }, { expr = true })

map("<leader>rf", function()
  return require("refactoring").refactor("Extract Function To File")
end, "Extract Function To File", { "n", "x" }, { expr = true })

map("<leader>rv", function()
  return require("refactoring").refactor("Extract Variable")
end, "Extract Variable", { "n", "x" }, { expr = true })

map("<leader>rI", function()
  return require("refactoring").refactor("Inline Function")
end, "Inline Function", { "n", "x" }, { expr = true })

map("<leader>ri", function()
  return require("refactoring").refactor("Inline Variable")
end, "Inline Variable", { "n", "x" }, { expr = true })

map("<leader>rbb", function()
  return require("refactoring").refactor("Extract Block")
end, "Extract Block", { "n", "x" }, { expr = true })

map("<leader>rbf", function()
  return require("refactoring").refactor("Extract Block To File")
end, "Extract Block To File", { "n", "x" }, { expr = true })

map("<leader>rp", function()
  require("refactoring").debug.print_var({})
end, "Print var", { "x", "n" })

map("<leader>rP", function()
  require("refactoring").debug.printf({ below = false })
end, "Print", "n")

map("<leader>rc", function()
  require("refactoring").debug.cleanup({})
end, "Cleanup", "n")
