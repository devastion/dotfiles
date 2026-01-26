---@type LazySpec
return {
  "tpope/vim-fugitive",
  keys = {
    {
      "<leader>gA",
      function()
        vim.cmd([[Git add %]])
      end,
      desc = "[A]dd file",
    },
    {
      "<leader>gR",
      function()
        vim.cmd([[Git restore %]])
      end,
      desc = "[R]estore file",
    },
  },
}
