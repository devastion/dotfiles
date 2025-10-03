vim.pack.add({ "https://github.com/folke/snacks.nvim" }, { confirm = false })

require("snacks").setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
  terminal = {
    win = { style = "float" },
  },
})

local map = require("devastion.utils").remap

map("]]", function() require("snacks.words").jump(vim.v.count1, false) end, "Next Word Reference")
map("[[", function() require("snacks.words").jump(-vim.v.count1, false) end, "Prev Word Reference")
map("<C-_>", function() require("snacks.terminal").toggle() end, "Toggle Terminal", { "n", "t" })
map("<C-/>", function() require("snacks.terminal").toggle() end, "Toggle Terminal", { "n", "t" })
map("grN", function() require("snacks.rename").rename_file() end, "Rename File")
map("<leader>go", function() require("snacks.gitbrowse").open() end, "Open File in Repository")

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesActionRename",
  callback = function(event) require("snacks.rename").on_rename_file(event.data.from, event.data.to) end,
})
