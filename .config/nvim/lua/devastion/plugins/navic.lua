vim.pack.add({ "https://github.com/SmiteshP/nvim-navic" }, { confirm = false })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buffer = args.buf ---@type number
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client and client:supports_method("textDocument/documentSymbol") then
      require("nvim-navic").attach(client, buffer)
    end
  end,
})
