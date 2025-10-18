vim.pack.add({ "https://github.com/artemave/workspace-diagnostics.nvim" }, { confirm = false })

vim.api.nvim_set_keymap("n", "<leader>cx", "", {
  noremap = true,
  callback = function()
    for _, client in ipairs(vim.lsp.get_clients()) do
      require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
    end
  end,
  desc = "Workspace Diagnostics",
})
