MiniDeps.later(function()
  MiniDeps.add({ source = "magicduck/grug-far.nvim" })

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
end)
