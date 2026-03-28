local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "nvim-mini/mini.files",
    data = {
      config = function()
        local files = require("mini.files")
        files.setup({
          options = {
            permanent_delete = false,
          },
        })
        map("<leader>e", function()
          files.open()
        end, "Files (root)")
        map("<leader>E", function()
          files.open(require("devastion.utils.path").get_bufname(), true)
        end, "Files (cwd)")
      end,
    },
  },
})
