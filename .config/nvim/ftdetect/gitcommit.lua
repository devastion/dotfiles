vim.api.nvim_create_autocmd("FileType", {
  desc = "Set colorcolumn for git commit messages",
  pattern = "gitcommit",
  callback = function() vim.wo.colorcolumn = "50,72" end,
})
