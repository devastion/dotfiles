require("devastion.utils.pkg").add({
  {
    src = "nvim-mini/mini.icons",
    data = {
      config = function()
        local icons = require("mini.icons")
        icons.setup({
          file = {
            ["dot_zshrc"] = { glyph = "󰒓", hl = "MiniIconsGreen" },
            ["dot_zshenv"] = { glyph = "󰒓", hl = "MiniIconsGreen" },
            ["dot_zprofile"] = { glyph = "󰒓", hl = "MiniIconsGreen" },
            ["dot_zlogout"] = { glyph = "󰒓", hl = "MiniIconsGreen" },
          },
        })
        icons.mock_nvim_web_devicons()
        icons.tweak_lsp_kind()
      end,
    },
  },
})
