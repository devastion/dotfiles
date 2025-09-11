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
