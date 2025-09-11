vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable csvview.nvim",
  pattern = "csv",
  callback = function()
    vim.pack.add({ "https://github.com/hat0uma/csvview.nvim" }, { confirm = false })

    local csvview = require("csvview")
    csvview.setup()
    csvview.enable()
  end,
})
