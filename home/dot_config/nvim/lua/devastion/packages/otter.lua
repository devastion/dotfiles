local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup

require("devastion.utils.pkg").add({
  {
    src = "jmbuhr/otter.nvim",
    data = {
      config = function()
        require("otter").setup()

        autocmd({ "FileType" }, {
          pattern = { "markdown", "toml" },
          group = augroup("embed_otter"),
          callback = function()
            if vim.bo.modifiable then
              require("otter").activate()
            end
          end,
        })
      end,
    },
  },
})
