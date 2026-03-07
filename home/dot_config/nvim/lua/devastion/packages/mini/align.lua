require("devastion.utils.pkg").add({
  {
    src = "nvim-mini/mini.align",
    data = {
      config = function()
        local align = require("mini.align")
        align.setup()
      end,
    },
  },
})
