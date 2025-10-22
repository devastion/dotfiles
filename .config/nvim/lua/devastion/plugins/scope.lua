---@type LazySpec
return {
  "tiagovla/scope.nvim",
  enabled = false,
  cmd = { "ScopeSaveState", "ScopeLoadState" },
  opts = {},
  init = function()
    vim.api.nvim_create_user_command("RestoreTabPagesName", function()
      local tabs = vim.api.nvim_list_tabpages()

      for i, _t in ipairs(tabs) do
        local custom_name = vim.g["TabPageCustomName" .. i]
        if custom_name and custom_name ~= "" then
          vim.api.nvim_tabpage_set_var(i, "name", custom_name)
        end
      end
    end, {
      desc = "Restore Tab Pages Name",
    })
  end,
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
          format_item = function(item)
            return item.text
          end,
        }, function(choice)
          if choice then
            vim.cmd("ScopeMoveBuf " .. choice.idx)
          end
        end)
      end,
      desc = "Move current buffer to tab",
    },
    {
      "<leader><tab>r",
      function()
        vim.ui.input({ prompt = "Tab Name: " }, function(name)
          local current_tab = vim.api.nvim_get_current_tabpage()
          if name then
            vim.g["TabPageCustomName" .. current_tab] = name
            vim.schedule(function()
              vim.api.nvim_tabpage_set_var(0, "name", name)
              vim.schedule(function()
                vim.cmd.redrawtabline()
              end)
            end)
          else
            vim.g["TabPageCustomName" .. current_tab] = nil
          end
        end)
      end,
      desc = "Rename Tab",
    },
  },
}
