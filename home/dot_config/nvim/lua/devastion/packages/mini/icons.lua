require("devastion.utils.pkg").add({
  {
    src = "nvim-mini/mini.icons",
    data = {
      config = function()
        local icons = require("mini.icons")
        icons.setup()
        icons.mock_nvim_web_devicons()
        icons.tweak_lsp_kind()
      end,
    },
  },
})
