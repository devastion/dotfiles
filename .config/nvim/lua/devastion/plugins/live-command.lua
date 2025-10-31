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
}
