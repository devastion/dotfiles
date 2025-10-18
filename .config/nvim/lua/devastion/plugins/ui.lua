---@type LazySpec
return {
  {
    "nvim-lualine/lualine.nvim",
    event = { "VeryLazy" },
    opts = function()
      local attached_clients = {
        require("devastion.utils").get_attached_clients,
        color = {
          gui = "bold",
        },
      }
      local signs = require("devastion.utils").diagnostic_signs

      return {
        theme = "tokyonight",
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = signs.ERROR,
                warn = signs.WARN,
                info = signs.INFO,
                hint = signs.HINT,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename" },
          },
          lualine_x = {
            {
              require("noice").api.statusline.mode.get,
              cond = require("noice").api.statusline.mode.has,
              color = { fg = "#ff9e64" },
            },
            attached_clients,
            "encoding",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      }
    end,
  },
  {
    "folke/noice.nvim",
    event = { "VeryLazy" },
    dependencies = {
      "muniftanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      cmdline = {
        enabled = true,
        format = {
          IncRename = {
            pattern = "^:%s*IncRename%s+",
            icon = " ",
            conceal = true,
            opts = {
              relative = "cursor",
              size = { min_width = 20 },
              position = { row = -3, col = 0 },
            },
          },
          search_down = {
            view = "cmdline",
          },
          search_up = {
            view = "cmdline",
          },
        },
      },
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
        cmdline_popupmenu = {
          relative = "editor",
          position = {
            row = 6,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
            max_height = 15,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "NoiceCmdlinePopupBorder" },
          },
        },
      },
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
      presets = {
        bottom_search = false,
        command_palette = false,
        long_message_to_split = false,
        inc_rename = false,
        lsp_doc_border = false,
      },
      messages = { enabled = true },
      popupmenu = { enabled = false },
      notify = { enabled = true, view = "notify" },
      lsp = {
        progress = { enabled = true },
        hover = { enabled = false },
        signature = { enabled = false },
        message = { enabled = false },
      },
      health = { checker = false },
    },
    keys = {
      {
        "<Esc>",
        function()
          require("noice").cmd("dismiss")
          local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
          vim.api.nvim_feedkeys(esc, "n", false)
        end,
      },
    },
  },
  {
    "brenoprata10/nvim-highlight-colors",
    opts = {
      render = "virtual",
      enable_named_colors = false,
      enable_tailwind = true,
      virtual_symbol = "󱓻",
    },
  },
  {
    "stevearc/quicker.nvim",
    ft = "qf",
    opts = {
      keys = {
        {
          ">",
          function()
            require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
          end,
          desc = "Expand quickfix context",
        },
        {
          "<",
          function()
            require("quicker").collapse()
          end,
          desc = "Collapse quickfix context",
        },
      },
    },
    keys = {
      {
        "<leader>q",
        function()
          require("quicker").toggle()
        end,
        desc = "Toggle Quickfix",
      },
      {
        "<leader>l",
        function()
          require("quicker").toggle({ loclist = true })
        end,
        desc = "Toggle Loclist",
      },
    },
  },
}
