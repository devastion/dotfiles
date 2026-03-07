local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup

require("devastion.utils.pkg").add({
  {
    src = "nvim-mini/mini.splitjoin",
    data = {
      config = function()
        require("mini.splitjoin").setup({
          mappings = { toggle = "J" },
        })
      end,
    },
  },
})

autocmd("FileType", {
  desc = "Lua specific mini.splitjoin config",
  group = augroup("mini_splitjoin"),
  pattern = { "lua" },
  callback = function(event)
    local gen_hook = require("mini.splitjoin").gen_hook
    local curly = { brackets = { "%b{}" } }

    local add_comma_curly = gen_hook.add_trailing_separator(curly)

    local del_comma_curly = gen_hook.del_trailing_separator(curly)

    local pad_curly = gen_hook.pad_brackets(curly)

    vim.b[event.buf].minisplitjoin_config = {
      split = { hooks_post = { add_comma_curly } },
      join = { hooks_post = { del_comma_curly, pad_curly } },
    }
  end,
})
