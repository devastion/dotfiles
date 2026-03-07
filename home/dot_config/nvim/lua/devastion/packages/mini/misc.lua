require("devastion.utils.pkg").add({
  {
    src = "nvim-mini/mini.misc",
    data = {
      config = function()
        local misc = require("mini.misc")
        misc.setup()
        misc.setup_auto_root()
        misc.setup_restore_cursor()
        misc.setup_termbg_sync()
      end,
    },
  },
})
