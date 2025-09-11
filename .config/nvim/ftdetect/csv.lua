vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable csvview.nvim",
  pattern = "csv",
  callback = function()
    MiniDeps.now(function()
      MiniDeps.add({ source = "hat0uma/csvview.nvim" })
      local csvview = require("csvview")
      csvview.setup()
      csvview.enable()
    end)
  end,
})
