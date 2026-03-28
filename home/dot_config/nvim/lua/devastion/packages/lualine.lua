require("devastion.utils.pkg").add({
  "nvim-lualine/lualine.nvim",
})

local function lint_progress()
  local linters = require("lint").get_running()
  if #linters == 0 then
    return "󰦕"
  end
  return "󱉶 " .. table.concat(linters, ", ")
end

local signs = vim.g.diagnostic_signs

local winbar = {
  lualine_a = {},
  lualine_b = {},
  lualine_c = {
    lint_progress,
    {
      function()
        return " "
      end,
      color = function()
        local status = require("sidekick.status").get()
        if status then
          return status.kind == "Error" and "DiagnosticError" or status.busy and "DiagnosticWarn" or "Special"
        end
      end,
      cond = function()
        local status = require("sidekick.status")
        return status.get() ~= nil
      end,
    },
    {
      function()
        local status = require("sidekick.status").cli()
        return " " .. (#status > 1 and #status or "")
      end,
      cond = function()
        return #require("sidekick.status").cli() > 0
      end,
      color = function()
        return "Special"
      end,
    },
    { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
    "filename",
  },
  lualine_x = {},
  lualine_y = {},
  lualine_z = { "tabs" },
}

require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = vim.o.laststatus == 3,
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {
      statusline = {},
      winbar = {
        "qf",
        "help",
        "gitcommit",
        "dap-repl",
        "dap-view",
        "dap-view-term",
        "dap-view-help",
      },
    },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      "branch",
    },
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
      {
        function()
          local warp = require("warp")
          local total = warp.count()
          local item = warp.get_item_by_buf(0)
          local current = item and item.index or "-"
          return string.format("󱐋 [%s/%s]", tonumber(current) or "-", tonumber(total))
        end,
        cond = function()
          local ok, warp = pcall(require, "warp")
          return ok and warp.count() > 0
        end,
        color = { fg = "#1abc9c", gui = "bold" },
      },
      -- { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      -- { "filename" },
    },
    lualine_x = {
      {
        require("noice").api.statusline.mode.get,
        cond = require("noice").api.statusline.mode.has,
        color = { fg = "#ff9e64" },
      },
      {
        function()
          local fname = vim.fn.expand("%:p")
          if fname == "" then
            return ""
          end
          return vim.fn.getfperm(fname)
        end,
        color = function()
          local fname = vim.fn.expand("%:p")
          if fname == "" then
            return {}
          end
          if vim.fn.executable(fname) == 1 then
            return { fg = "#f7768e" } -- red for executable
          elseif vim.fn.filewritable(fname) == 1 then
            return { fg = "#9ece6a" } -- green for writable
          else
            return { fg = "#565f89" } -- gray for read-only
          end
        end,
        cond = function()
          return vim.fn.expand("%:p") ~= ""
        end,
      },
      "encoding",
      "filetype",
    },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },

  winbar = winbar,

  inactive_winbar = winbar,
})
