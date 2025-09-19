vim.pack.add({ "https://github.com/rmagatti/auto-session" }, { confirm = false })

local options = {
  bypass_save_filetypes = { "gitcommit" },
  close_filetypes_on_save = { "checkhealth", "help" },
  git_use_branch_name = true,
  git_auto_restore_on_branch_change = true,
}

if package.loaded["scope"] then
  vim.schedule(function() vim.notify("scope loaded") end)
  options.pre_save_cmds = { "ScopeSaveState" }
  options.post_restore_cmds = { "ScopeLoadState", "RestoreTabPagesName", "TSContext enable" }
end

require("auto-session").setup(options)
