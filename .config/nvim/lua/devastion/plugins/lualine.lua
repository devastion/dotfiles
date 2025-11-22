---@type LazySpec
return {
  "nvim-lualine/lualine.nvim",
  event = { "VeryLazy" },
  dependencies = {
    "andrem222/copilot-lualine",
  },
  opts = function()
    local signs = vim.g.diagnostic_signs

    return {
      options = {
        theme = "auto",
        globalstatus = vim.o.laststatus == 3,
      },
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
          require("ecolog.integrations.statusline").lualine(),
          "copilot",
          "encoding",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    }
  end,
}
