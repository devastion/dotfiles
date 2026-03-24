local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "chentoast/marks.nvim",
    data = {
      event = { "BufReadPost", "BufWritePost", "BufNewFile" },
      config = function()
        require("marks").setup({
          default_mappings = true,
          builtin_marks = {},
          cyclic = true,
          force_write_shada = false,
          refresh_interval = 250,
          sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
          excluded_filetypes = {
            "gitcommit",
            "noice",
            "warp-list",
            "notify",
            "minifiles",
          },
          excluded_buftypes = {},
          mappings = {},
        })

        map("m", "<Nop>", "+[Marks]")

        map("ma", function()
          require("marks").toggle()
        end, "Toggle Mark")
        for i = string.byte("b"), string.byte("z") do
          local c = string.char(i)

          map("m" .. c, function()
            vim.cmd("normal! m" .. c)
          end)

          map("m" .. c:upper(), function()
            vim.cmd("normal! m" .. c:upper())
          end)
        end

        map("]m", function()
          require("marks").next()
        end, "Next Mark")
        map("[m", function()
          require("marks").prev()
        end, "Prev Mark")
        map("m<space>", function()
          if vim.v.operator == "d" then
            require("marks").delete_buf()
          end
        end, "Delete Buffer Marks", "o")
      end,
    },
  },
})
