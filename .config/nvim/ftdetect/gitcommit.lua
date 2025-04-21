vim.api.nvim_create_autocmd("FileType", {
  desc = "Set colorcolumn for git commit messages",
  group = vim.api.nvim_create_augroup("__gitcommit", { clear = true }),
  pattern = "gitcommit",
  callback = function() vim.opt_local.colorcolumn = "51,73" end,
})
