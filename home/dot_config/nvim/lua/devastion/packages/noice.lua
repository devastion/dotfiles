local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup
local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "rcarriga/nvim-notify",
    data = {
      config = function()
        require("notify").setup({
          render = "minimal",
          timeout = 2000,
          stages = "static",
        })
      end,
    },
  },
  {
    src = "folke/noice.nvim",
    data = {
      init = function()
        autocmd("FileType", {
          group = augroup("wrap_noice"),
          pattern = { "noice" },
          callback = function(event)
            vim.schedule(function()
              vim.wo[vim.fn.bufwinid(event.buf)].wrap = true
            end)
          end,
        })
      end,
      config = function()
        require("noice").setup({
          views = {
            cmdline_popup = {
              position = {
                row = 10,
                col = "50%",
              },
              size = {
                min_width = 60,
                width = "auto",
                height = "auto",
              },
            },
          },
          cmdline = {
            enabled = true,
            view = "cmdline_popup",
            opts = {},
            format = {
              cmdline = { pattern = "^:", icon = "", lang = "vim" },
              search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
              search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
              filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
              lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
              help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
              input = { view = "cmdline_input", icon = "󰥻 " },
            },
          },
          messages = {
            enabled = true,
            view = "notify",
            view_error = "notify",
            view_warn = "notify",
            view_history = "messages",
            view_search = "virtualtext",
          },
          popupmenu = {
            enabled = false,
          },
          redirect = {
            view = "popup",
            filter = { event = "msg_show" },
          },
          commands = {
            history = {
              view = "popup",
              opts = { enter = true, format = "details" },
              filter = {
                any = {
                  { event = "notify" },
                  { error = true },
                  { warning = true },
                  { event = "msg_show", kind = { "" } },
                  { event = "lsp", kind = "message" },
                },
              },
            },
            last = {
              view = "popup",
              opts = { enter = true, format = "details" },
              filter = {
                any = {
                  { event = "notify" },
                  { error = true },
                  { warning = true },
                  { event = "msg_show", kind = { "" } },
                  { event = "lsp", kind = "message" },
                },
              },
              filter_opts = { count = 1 },
            },
            errors = {
              view = "popup",
              opts = { enter = true, format = "details" },
              filter = { error = true },
              filter_opts = { reverse = true },
            },
            all = {
              view = "popup",
              opts = { enter = true, format = "details" },
              filter = {},
            },
          },
          notify = {
            enabled = true,
            view = "notify",
          },
          lsp = {
            progress = {
              enabled = true,
              format = "lsp_progress",
              format_done = "lsp_progress_done",
              throttle = 1000 / 30, -- frequency to update lsp progress message
              view = "mini",
            },
            override = {
              ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
              ["vim.lsp.util.stylize_markdown"] = false,
            },
            hover = {
              enabled = false,
            },
            signature = {
              enabled = false,
            },
            message = {
              enabled = true,
              view = "notify",
              opts = {},
            },
            documentation = {
              enabled = false,
            },
          },
          markdown = {
            hover = {
              ["|(%S-)|"] = vim.cmd.help, -- vim help links
              ["%[.-%]%((%S-)%)"] = require("noice.util").open, -- markdown links
            },
            highlights = {
              ["|%S-|"] = "@text.reference",
              ["@%S+"] = "@parameter",
              ["^%s*(Parameters:)"] = "@text.title",
              ["^%s*(Return:)"] = "@text.title",
              ["^%s*(See also:)"] = "@text.title",
              ["{%S-}"] = "@parameter",
            },
          },
          health = {
            checker = false,
          },
          throttle = 1000 / 30,
          routes = {
            {
              filter = {
                event = "msg_show",
                any = {
                  { find = "%d+L, %d+B" },
                  { find = "; after #%d+" },
                  { find = "; before #%d+" },
                  { find = "%d fewer lines" },
                  { find = "%d more lines" },
                },
              },
              opts = { skip = true },
            },
            {
              view = "notify",
              filter = { event = "msg_showmode" },
            },
          },
        })

        map("<esc>", function()
          require("noice").cmd("dismiss")
          local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
          vim.api.nvim_feedkeys(esc, "n", false)
        end, "Dismiss Noice")

        map("<leader>nh", function()
          require("noice").cmd("history")
        end, "Noice History")

        map("<leader>na", function()
          require("noice").cmd("all")
        end, "Noice All")

        map("<leader>nl", function()
          require("noice").cmd("last")
        end, "Noice Last")

        map("<leader>ne", function()
          require("noice").cmd("errors")
        end, "Noice Errors")
      end,
    },
  },
})
