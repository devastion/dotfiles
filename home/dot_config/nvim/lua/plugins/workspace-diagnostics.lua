vim.pack.add({
  'https://github.com/artemave/workspace-diagnostics.nvim',
}, { confirm = false })

local skipped = {
  'copilot',
  'cspell_ls',
}

vim.lsp.config('*', {
  on_attach = function(client, bufnr)
    if vim.tbl_contains(skipped, client.name) then return end

    vim.schedule(function()
      if not client:is_stopped() then
        if client:supports_method('workspace/diagnostic', bufnr) then
          vim.lsp.buf.workspace_diagnostics({ client_id = client.id })
        else
          require('workspace-diagnostics').populate_workspace_diagnostics(
            client,
            bufnr
          )
        end
      end
    end)
  end,
})
