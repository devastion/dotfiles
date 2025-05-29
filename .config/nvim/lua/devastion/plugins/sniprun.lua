---@type LazySpec
return {
  "michaelb/sniprun",
  branch = "master",
  build = "sh install.sh",
  cmd = {
    "SnipRun",
    "SnipInfo",
    "SnipReset",
    "SnipReplMemoryClean",
    "SnipClose",
    "SnipLive",
  },
  opts = {
    live_mode_toggle = "enable",
    display = {
      "TempFloatingWindow",
    },
  },
  keys = {
    { "<leader>rr", function() require("sniprun").run() end, desc = "Run" },
    { "<leader>ri", function() require("sniprun").info() end, desc = "Info" },
    { "<leader>rR", function() require("sniprun").reset() end, desc = "Reset" },
    { "<leader>rm", function() require("sniprun").clear_repl() end, desc = "REPL Memory Clean" },
    { "<leader>rq", function() require("sniprun.display").close_all() end, desc = "Close" },
    { "<leader>rl", function() require("sniprun.live_mode").toggle() end, desc = "Toggle Live" },
  },
}
