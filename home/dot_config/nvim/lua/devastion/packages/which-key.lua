require("devastion.utils.pkg").add({
  {
    src = "folke/which-key.nvim",
    data = {
      config = function()
        local wk = require("which-key")

        wk.setup({
          preset = "helix",
          delay = 0,
          filter = function(mapping)
            return mapping.desc and mapping.desc ~= ""
          end,
          triggers = {
            { "<auto>", mode = "nixsotc" },
            { "s", mode = { "n", "x" } },
            { "m", mode = { "n" } },
          },
          sort = { "order", "group", "alphanum" },
          icons = {
            mappings = true,
            keys = {
              Space = "Space ",
              Esc = "Esc ",
              BS = "Backspace ",
              C = "Ctrl ",
            },
          },
        })

        wk.add({
          { "<leader>f", group = "+[Find]", mode = { "n", "x" } },
          { "<leader>c", group = "+[Code]", mode = { "n", "x" } },
          { "<leader>s", group = "+[Search]", mode = { "n", "x" } },
          { "<leader>g", group = "+[Git]", mode = { "n", "x" } },
          { "<leader>gh", group = "+[Hunks]", mode = { "n", "x" } },
          { "<leader>gt", group = "+[Toggles]" },
          { "<leader>gx", group = "+[Conflicts]", mode = { "n", "x" } },
          { "<leader>n", group = "+[Notifications]" },
          { "<leader>a", group = "+[AI]", mode = { "n", "x" } },
          { "<leader><tab>", group = "+[Tabs]" },
          { "<leader>u", group = "+[Toggles]" },
          { "<leader>P", group = "+[Packages]", icon = require("mini.icons").get("lsp", "package") },
          { "gr", group = "+[LSP]" },
          { "gc", group = "+[Comment]", mode = { "n", "o" } },
          { "[", group = "+[Prev]", mode = { "n", "x", "o" } },
          { "]", group = "+[Next]", mode = { "n", "x", "o" } },
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
        })
      end,
    },
  },
})
