---@type LazySpec
return {
  "akinsho/git-conflict.nvim",
  version = "*",
  opts = {
    default_mappings = false,
    default_commands = true,
    disable_diagnostics = false,
  },
  config = function(_, opts)
    require("git-conflict").setup(opts)
  end,
  keys = function()
    return {
      {
        "<leader>gx",
        "",
        desc = "+[Conflicts]",
      },
      {
        "]x",
        function()
          require("git-conflict").find_next("ours")
        end,
        desc = "Next Conflict",
      },
      {
        "[x",
        function()
          require("git-conflict").find_prev("ours")
        end,
        desc = "Prev Conflict",
      },
      {
        "<leader>gxx",
        function()
          require("which-key").show({ keys = "<leader>gx", loop = true })
        end,
        desc = "Hydra Mode",
      },
      {
        "<leader>gxn",
        function()
          require("git-conflict").find_next("ours")
        end,
        desc = "Next Conflict",
      },
      {
        "<leader>gxp",
        function()
          require("git-conflict").find_prev("ours")
        end,
        desc = "Prev Conflict",
      },
      {
        "<leader>gxo",
        function()
          require("git-conflict").choose("ours")
        end,
        desc = "Choose Ours",
      },
      {
        "<leader>gxt",
        function()
          require("git-conflict").choose("theirs")
        end,
        desc = "Choose Theirs",
      },
      {
        "<leader>gxb",
        function()
          require("git-conflict").choose("both")
        end,
        desc = "Choose Both",
      },
      {
        "<leader>gx0",
        function()
          require("git-conflict").choose("none")
        end,
        desc = "Choose None",
      },
      {
        "<leader>gxq",
        function()
          vim.cmd("GitConflictListQf")
        end,
        desc = "Quickfix List",
      },
      {
        "<leader>gxr",
        function()
          vim.cmd("GitConflictRefresh")
        end,
        desc = "Refresh Conflicts",
      },
    }
  end,
}
