local usercmd = vim.api.nvim_create_user_command

usercmd("ToggleLspClient", function()
  local lsp_configs = require("devastion.helpers.lsp").get_lsp_configs()

  vim.ui.select(lsp_configs, {
    prompt = "Select LSP Client:",
  }, function(choice)
    if choice then
      local is_active = require("devastion.helpers.lsp").is_lsp_client_active(choice)
      vim.lsp.enable(choice, not is_active)

      vim.notify(choice .. " " .. (is_active and "deactivated" or "activated"), vim.log.levels.INFO)
    end
  end)
end, { desc = "Toggle LSP Client" })

usercmd("LspListActiveClients", function()
  vim.notify(vim.inspect(Devastion.lsp.get_attached_clients()), vim.log.levels.INFO)
end, { desc = "List Active LSP Clients" })
