---@type LazySpec
return {
  "apple/pkl-neovim",
  lazy = true,
  ft = "pkl",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter",
      build = function(_)
        vim.cmd("TSUpdate")
      end,
    },
  },
  build = function()
    require("pkl-neovim").init()

    -- Set up syntax highlighting.
    require("devastion.utils").ts_install({ "pkl" })
  end,
  config = function()
    -- Configure pkl-lsp
    vim.g.pkl_neovim = {
      start_command = { "pkl-lsp" },
    }
  end,
}
