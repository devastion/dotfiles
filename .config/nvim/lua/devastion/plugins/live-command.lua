---@type LazySpec
return {
  "smjonas/live-command.nvim",
  event = {
    "CmdLineEnter",
  },
  cmd = {
    "LiveCommand",
    "Preview",
  },
  opts = {
    commands = {
      Norm = {
        cmd = "norm",
      },
    },
  },
  config = function(_, opts)
    require("live-command").setup(opts)
  end,
}
