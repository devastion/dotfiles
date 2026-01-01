---@type LazySpec
return {
  "stackinthewild/headhunter.nvim",
  opts = {
    enabled = true,
    keys = {
      prev = "[x",
      next = "]x",
      take_head = "<leader>gxh",
      take_origin = "<leader>gxo",
      take_both = "<leader>gxb",
      quickfix = "<leader>gxq",
    },
  },
  config = function(_, opts)
    require("headhunter").setup(opts)
  end,
}
