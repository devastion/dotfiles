---@type LazySpec
return {
  "ray-x/lsp_signature.nvim",
  event = "InsertEnter",
  opts = {
    bind = true,
    handler_opts = {
      border = vim.g.ui_border,
    },
  },
}
