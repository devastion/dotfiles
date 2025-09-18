vim.pack.add({ "https://github.com/rmagatti/auto-session" }, { confirm = false })
require("auto-session").setup({
  bypass_save_filetypes = { "gitcommit" },
  close_filetypes_on_save = { "checkhealth", "help" },
  git_use_branch_name = true,
  git_auto_restore_on_branch_change = true,
  pre_save_cmds = {
    "ScopeSaveState",
  },
  post_restore_cmds = { "ScopeLoadState", "RestoreTabPagesName", "TSContext enable" },
})
