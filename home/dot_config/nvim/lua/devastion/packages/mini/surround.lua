local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup

require("devastion.utils.pkg").add({
  {
    src = "nvim-mini/mini.surround",
    data = {
      config = function()
        local surround = require("mini.surround")
        surround.setup({
          mappings = {
            add = "sa",
            delete = "sd",
            replace = "sr",
            find = "",
            find_left = "",
            highlight = "sh",
            update_n_lines = "",
            suffix_last = "",
            suffix_next = "",
          },
          n_lines = 500,
        })
      end,
    },
  },
})

autocmd("FileType", {
  desc = "Markdown specific mini.surround config",
  group = augroup("mini_surround"),
  pattern = { "markdown" },
  callback = function(event)
    vim.b[event.buf].minisurround_config = {
      custom_surroundings = {
        L = {
          input = { "%[().-()%]%(.-%)" },
          output = function()
            local link = require("mini.surround").user_input("Link: ")
            return { left = "[", right = "](" .. link .. ")" }
          end,
        },
      },
    }
  end,
})
