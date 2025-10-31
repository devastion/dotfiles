---@type LazySpec
return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = { "InsertEnter", "BufReadPost" },
  dependencies = {
    {
      "copilotlsp-nvim/copilot-lsp",
      init = function()
        vim.g.copilot_nes_debounce = 500
      end,
    },
  },
  opts = {
    server_opts_overrides = {
      settings = {
        telemetry = {
          telemetryLevel = "off",
        },
      },
    },
    suggestion = {
      enabled = false,
    },
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      help = true,
    },
    nes = {
      enabled = false,
      auto_trigger = false,
      keymap = {
        accept_and_goto = "<leader>P",
        accept = false,
        dismiss = "<Esc>",
      },
    },
  },
}
