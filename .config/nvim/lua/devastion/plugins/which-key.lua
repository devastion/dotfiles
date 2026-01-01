---@type LazySpec
return {
  "folke/which-key.nvim",
  event = { "VeryLazy" },
  opts = function()
    return {
      preset = "helix",
      delay = 0,
      spec = {
        { "<leader>f", group = "+[Find]", mode = { "n", "v" } },
        { "<leader>c", group = "+[Code]", mode = { "n", "v" } },
        { "<leader>s", group = "+[Search]", mode = { "n", "v" } },
        { "<leader>g", group = "+[Git]", mode = { "n", "v" } },
        { "<leader>gh", group = "+[Hunks]", mode = { "n", "v" } },
        { "<leader>gx", group = "+[Conflicts]" },
        { "<leader>gt", group = "+[Toggles]" },
        { "<leader>u", group = "+[UI Toggles]", mode = { "n", "v" } },
        { "<leader><tab>", group = "+[Tabs]" },
        { "gr", group = "+[LSP]" },
        { "gc", group = "+[Comment]" },
        { "[", group = "+[Prev]", mode = { "n", "v", "o" } },
        { "]", group = "+[Next]", mode = { "n", "v", "o" } },
        { "g", group = "+[Goto]" },
        { "z", group = "+[Fold]" },
        { "s", group = "+[Surround/Operators]" },
        {
          "<leader>b",
          group = "+[Buffers]",
          expand = function()
            return require("which-key.extras").expand.buf()
          end,
        },
        {
          "<c-w>",
          group = "+[Windows]",
          expand = function()
            return require("which-key.extras").expand.win()
          end,
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
        { "s", mode = { "n", "v" } },
      },
      sort = { "order", "group", "alphanum" },
    }
  end,
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Keymaps (which-key)",
    },
    {
      "<c-w><space>",
      function()
        require("which-key").show({ keys = "<c-w>", loop = true })
      end,
      desc = "Window Hydra Mode (which-key)",
    },
  },
}
