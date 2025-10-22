---@type LazySpec
return {
  "rmagatti/auto-session",
  lazy = false,
  opts = {
    bypass_save_filetypes = { "gitcommit" },
    close_filetypes_on_save = { "checkhealth", "help" },
    git_use_branch_name = true,
    git_auto_restore_on_branch_change = true,
  },
}
