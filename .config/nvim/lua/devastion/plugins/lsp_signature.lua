---@type LazySpec
return {
  "ray-x/lsp_signature.nvim",
  event = "InsertEnter",
  opts = {
    bind = true,
    hint_prefix = {
      above = "↙ ",
      current = "← ",
      below = "↖ ",
    },
    hint_inline = function()
      return "eol"
    end,
    handler_opts = {
      border = vim.g.ui_border,
    },
  },
}
