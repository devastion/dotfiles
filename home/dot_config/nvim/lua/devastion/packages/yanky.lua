local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "gbprod/yanky.nvim",
    data = {
      config = function()
        require("yanky").setup({
          ring = {
            history_length = 10000,
            storage = "sqlite",
            storage_path = vim.fn.stdpath("data") .. "/databases/yanky.db",
            sync_with_numbered_registers = true,
            cancel_event = "update",
            ignore_registers = { "_" },
            update_register_on_cycle = false,
            permanent_wrapper = nil,
          },
          picker = {
            select = {
              action = nil,
            },
            telescope = {
              use_default_mappings = false,
              mappings = nil,
            },
          },
          system_clipboard = {
            sync_with_ring = true,
            clipboard_register = nil,
          },
          highlight = {
            on_put = false,
            on_yank = false,
            timer = 500,
          },
          preserve_cursor_position = {
            enabled = true,
          },
          textobj = {
            enabled = true,
          },
        })

        map("<leader>p", "<cmd>YankyRingHistory<cr>", "Yanky")
        map("y", "<Plug>(YankyYank)", "Yanky yank", { "n", "x" })
        map("p", "<Plug>(YankyPutAfter)", "Put after", { "n", "x" })
        map("P", "<Plug>(YankyPutBefore)", "Put before", { "n", "x" })
        map("gp", "<Plug>(YankyGPutAfter)", "GPut after", { "n", "x" })
        map("gP", "<Plug>(YankyGPutBefore)", "GPut before", { "n", "x" })
        map("[y", "<Plug>(YankyPreviousEntry)", "Yank previous entry")
        map("]y", "<Plug>(YankyNextEntry)", "Yank next entry")
        map("]p", "<Plug>(YankyPutIndentAfterLinewise)", "Put indent after linewise")
        map("[p", "<Plug>(YankyPutIndentBeforeLinewise)", "Put indent before linewise")
        map("]P", "<Plug>(YankyPutIndentAfterLinewise)", "Put indent after linewise")
        map("[P", "<Plug>(YankyPutIndentBeforeLinewise)", "Put indent before linewise")
        map(">p", "<Plug>(YankyPutIndentAfterShiftRight)", "Put indent after shift right")
        map("<p", "<Plug>(YankyPutIndentAfterShiftLeft)", "Put indent after shift left")
        map(">P", "<Plug>(YankyPutIndentBeforeShiftRight)", "Put indent before shift right")
        map("<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", "Put indent before shift left")
        map("=p", "<Plug>(YankyPutAfterFilter)", "Put after filter")
        map("=P", "<Plug>(YankyPutBeforeFilter)", "Put before filter")
        map("iy", function()
          require("yanky.textobj").last_put()
        end, "Last Put", { "o", "x" })
      end,
    },
  },
})
