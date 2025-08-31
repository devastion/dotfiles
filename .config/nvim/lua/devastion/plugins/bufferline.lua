---@type LazySpec
return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  version = "*",
  dependencies = { "echasnovski/mini.icons" },
  opts = {
    options = {
      close_command = function(n) Snacks.bufdelete(n) end,
      numbers = "none",
      diagnostics = "nvim_lsp",
      show_buffer_close_icons = false,
      show_close_icon = false,
      sort_by = "id",
    },
  },
  keys = function()
    local bufferline = require("bufferline")

    return {
      {
        "<leader>bd",
        function() Snacks.bufdelete() end,
        desc = "Delete",
      },
      {
        "<leader>bo",
        function() Snacks.bufdelete.other() end,
        desc = "Delete Other",
      },
      {
        "<leader>bp",
        function() bufferline.groups.toggle_pin() end,
        desc = "Toggle Pin",
      },
      {
        "<leader>bP",
        function() bufferline.groups.action("ungrouped", "close") end,
        desc = "Delete Non-Pinned",
      },
      {
        "<leader>bl",
        function() bufferline.close_in_direction("right") end,
        desc = "Delete to the Right",
      },
      {
        "<leader>bh",
        function() bufferline.close_in_direction("left") end,
        desc = "Delete to the Reft",
      },
      {
        "[b",
        function() bufferline.cycle(-1) end,
        desc = "Prev Buffer",
      },
      {
        "]b",
        function() bufferline.cycle(1) end,
        desc = "Next Buffer",
      },
      {
        "[B",
        function() bufferline.move(-1) end,
        desc = "Move Buffer Prev",
      },
      {
        "]B",
        function() bufferline.move(1) end,
        desc = "Move Buffer Next",
      },
      {
        "<leader>bb",
        function() pcall(vim.cmd.e, "#") end,
        desc = "Switch to Other Buffer",
      },
      {
        "<leader>`",
        function() pcall(vim.cmd.e, "#") end,
        desc = "Switch to Other Buffer",
      },
      {
        "<leader>bn",
        function() vim.cmd.enew() end,
        desc = "New File",
      },
      {
        "<leader>b0",
        function() vim.cmd("bfirst") end,
        desc = "First Buffer",
      },
      {
        "<leader>b$",
        function() vim.cmd("blast") end,
        desc = "Last Buffer",
      },
    }
  end,
}
