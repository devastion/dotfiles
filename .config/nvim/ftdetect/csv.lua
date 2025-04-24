vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable csvview.nvim",
  group = vim.api.nvim_create_augroup("__csv", { clear = true }),
  pattern = "csv",
  callback = function() require("csvview").enable() end,
})
