---@type LazySpec
return {
  "rmagatti/auto-session",
  lazy = false,
  dependencies = {
    {
      "tiagovla/scope.nvim",
      opts = {},
    },
  },
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    bypass_save_filetypes = { "gitcommit" },
    close_filetypes_on_save = { "checkhealth", "help" },
    git_use_branch_name = true,
    git_auto_restore_on_branch_change = true,
    pre_save_cmds = {
      "ScopeSaveState",
    },
    post_restore_cmds = { "ScopeLoadState", "RestoreTabPagesName" },
  },
  keys = {
    {
      "<leader>b<tab>",
      function()
        local tabs = vim.api.nvim_list_tabpages()
        local current_tab = vim.api.nvim_get_current_tabpage()
        local items = {}

        for i, t in ipairs(tabs) do
          if t ~= current_tab then
            local tab_name = vim.g["TabPageCustomName" .. i] or i

            table.insert(items, {
              idx = i,
              text = "Tab: " .. tab_name,
              tab = t,
            })
          end
        end

        vim.ui.select(items, {
          prompt = "Select a tab page:",
          format_item = function(item) return item.text end,
        }, function(choice)
          if choice then
            vim.cmd("ScopeMoveBuf " .. choice.idx)
          end
        end)
      end,
      desc = "Move current buffer to tab",
    },
  },
}
