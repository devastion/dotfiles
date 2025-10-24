---@type LazySpec
return {
  "folke/noice.nvim",
  event = { "VeryLazy" },
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
      message = { enabled = true },
    },
    health = { checker = false },
  },
  keys = {
    {
      "<esc>",
      function()
        require("noice").cmd("dismiss")
        local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
        vim.api.nvim_feedkeys(esc, "n", false)
      end,
    },
    {
      "<leader>sn",
      function()
        require("noice").cmd("pick")
      end,
      desc = "Noice",
    },
  },
}
