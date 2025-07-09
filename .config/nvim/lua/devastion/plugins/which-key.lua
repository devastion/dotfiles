---@type LazySpec
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  ---@class wk.Opts
  opts = function()
    local constants = require("devastion.utils.constants")
    local leader_keys = constants.leader_keys
    return {
      preset = "modern",
      delay = 0,
      spec = {
        { "<leader>a", group = "+[Avante]", mode = { "n", "v" } },
        { "<leader>f", group = "+[Find]" },
        { "<leader>c", group = "+[Code]", mode = { "n", "v" } },
        { "<leader>s", group = "+[Search]", mode = { "n", "v" } },
        { "<leader>g", group = "+[Git]", mode = { "n", "v" } },
        { "<leader><tab>", group = "+[Tabs]" },
        { "<leader>d", group = "+[Debugger]" },
        { "<leader>t", group = "+[Test]" },
        { "<leader>r", group = "+[Run]" },
        { "<leader>P", group = "+[Plugins]" },
        { leader_keys.toggles, group = "+[UI Toggles]" },
        { "gr", group = "+[LSP]" },
        { "[", group = "+[Prev]" },
        { "]", group = "+[Next]" },
        { "g", group = "+[Goto]" },
        { "z", group = "+[Fold]" },
        { "s", group = "+[Surround/Operators]" },
        {
          "<leader>b",
          group = "+[Buffers]",
          expand = function() return require("which-key.extras").expand.buf() end,
        },
        {
          "<C-w>",
          group = "+[Windows]",
          expand = function() return require("which-key.extras").expand.win() end,
        },
      },
      icons = {
        mappings = true,
        keys = {
          Space = "Space",
          Esc = "Esc",
          BS = "Backspace",
          C = "Ctrl-",
        },
      },
      triggers = {
        { "<auto>", mode = "nixsotc" },
        { "s", mode = "nx" },
      },
    }
  end,
}
