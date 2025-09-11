vim.pack.add({ "https://github.com/magicduck/grug-far.nvim" }, { confirm = false })

require("grug-far").setup({ headerMaxWidth = 80 })

vim.keymap.set("n", "<leader>cR", function()
  local grug = require("grug-far")
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  grug.open({
    transient = true,
    prefills = {
      filesFilter = ext and ext ~= "" and "*." .. ext or nil,
    },
  })
end, { desc = "Search and Replace" })
