local map = require("devastion.utils").map
local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup

require("devastion.utils.pkg").add({
  {
    src = "y3owk1n/warp.nvim",
    data = {
      event = { "BufReadPost", "BufWritePost", "BufNewFile" },
      config = function()
        require("warp").setup(
          ---@type Warp.Config
          {
            auto_prune = true,
            root_markers = { ".git" },
            root_detection_fn = vim.fn.getcwd,
            list_item_format_fn = require("warp.builtins").list_item_format_fn,
            keymaps = {
              quit = { "q", "<Esc>" },
              select = { "<CR>" },
              delete = { "dd" },
              move_up = { "<M-k>" },
              move_down = { "<M-j>" },
              split_horizontal = { "<C-w>s" },
              split_vertical = { "<C-w>v" },
              show_help = { "g?" },
            },
            window = {
              list = {
                title = "list (warp.nvim)",
              },
              help = {
                title = "help (warp.nvim)",
              },
            },
            hl_groups = {
              --- list window hl
              list_normal = { link = "Normal" },
              list_border = { link = "FloatBorder" },
              list_title = { link = "FloatTitle" },
              list_footer = { link = "FloatFooter" },
              list_cursor_line = { link = "CursorLine" },
              list_item_active = { link = "Added" },
              list_item_error = { link = "Error" },
              --- help window hl
              help_normal = { link = "Normal" },
              help_border = { link = "FloatBorder" },
              help_title = { link = "FloatTitle" },
              help_footer = { link = "FloatFooter" },
              help_cursor_line = { link = "CursorLine" },
            },
          }
        )

        local leader = "<s-m>"
        require("which-key").add({
          { leader .. "", group = "+[Warp]" },
        })

        -- Actions
        map("<c-e>", function()
          require("warp").show_list()
        end, "Show list [warp]")

        map(leader .. "a", function()
          require("warp").add()
          vim.notify("Added " .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t") .. " to warp")
        end, "Add")
        map(leader .. "d", function()
          require("warp").del()
          vim.notify("Deleted " .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t") .. " from warp")
        end, "Delete")
        map(leader .. "l", function()
          require("warp").show_list()
        end, "Show list")
        map(leader .. "A", function()
          require("warp").add_all_onscreen()
        end, "Add all on screen files")

        -- Clear
        map(leader .. "x", function()
          require("warp").clear_current_list()
        end, "Clear current list")
        map(leader .. "X", function()
          require("warp").clear_all_list()
        end, "Clear all lists")

        -- Go to navigation
        map(leader .. "]", function()
          require("warp").goto_index("next")
        end, "Goto next index")
        map(leader .. "[", function()
          require("warp").goto_index("prev")
        end, "Goto prev index")
        map(leader .. "0", function()
          require("warp").goto_index("first")
        end, "Goto first index")
        map(leader .. "$", function()
          require("warp").goto_index("last")
        end, "Goto last index")

        -- Direct index
        map(leader .. "1", function()
          require("warp").goto_index(1)
        end, "Goto #1")
        map(leader .. "2", function()
          require("warp").goto_index(2)
        end, "Goto #2")
        map(leader .. "3", function()
          require("warp").goto_index(3)
        end, "Goto #3")
        map(leader .. "4", function()
          require("warp").goto_index(4)
        end, "Goto #4")

        autocmd("User", {
          group = augroup("warp_mini_files"),
          pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
          callback = function(ev)
            local from, to = ev.data.from, ev.data.to

            local warp_exists, warp = pcall(require, "warp")
            if warp_exists then
              warp.on_file_update(from, to)
            end
          end,
        })
      end,
    },
  },
})
