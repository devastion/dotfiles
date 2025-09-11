vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Disable diagnostics for env files",
  pattern = "*.env*",
  callback = function()
    vim.diagnostic.enable(false)
    vim.notify("Diagnostics are disabled for env files (.env*)")
  end,
})
