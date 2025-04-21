---@type LazySpec
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
    })

    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open({}) end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close({}) end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close({}) end

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
    vim.api.nvim_set_hl(0, "DapBreak", { fg = "#e51400" })
    vim.api.nvim_set_hl(0, "DapStop", { fg = "#ffcc00" })
    local breakpoint_icons = {
      Breakpoint = "",
      BreakpointCondition = "",
      BreakpointRejected = "",
      LogPoint = "",
      Stopped = "",
    }

    for type, icon in pairs(breakpoint_icons) do
      local tp = "Dap" .. type
      local hl = (type == "Stopped") and "DapStop" or "DapBreak"
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    -- setup dap from vscode launch.json
    local vscode = require("dap.ext.vscode")
    local json = require("plenary.json")
    vscode.json_decode = function(str) return vim.json.decode(json.json_strip_comments(str)) end
  end,
  keys = {
    {
      "<leader>dB",
      function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
      desc = "Breakpoint Condition",
    },
    {
      "<leader>db",
      function() require("dap").toggle_breakpoint() end,
      desc = "Toggle Breakpoint",
    },
    {
      "<leader>dc",
      function() require("dap").continue() end,
      desc = "Run/Continue",
    },
    {
      "<leader>da",
      function() require("dap").continue({ before = require("devastion.utils.plugins").dap_get_args }) end,
      desc = "Run with Args",
    },
    {
      "<leader>dC",
      function() require("dap").run_to_cursor() end,
      desc = "Run to Cursor",
    },
    {
      "<leader>dg",
      function() require("dap").goto_() end,
      desc = "Go to Line (No Execute)",
    },
    {
      "<leader>di",
      function() require("dap").step_into() end,
      desc = "Step Into",
    },
    {
      "<leader>dj",
      function() require("dap").down() end,
      desc = "Down",
    },
    {
      "<leader>dk",
      function() require("dap").up() end,
      desc = "Up",
    },
    {
      "<leader>dl",
      function() require("dap").run_last() end,
      desc = "Run Last",
    },
    {
      "<leader>do",
      function() require("dap").step_out() end,
      desc = "Step Out",
    },
    {
      "<leader>dO",
      function() require("dap").step_over() end,
      desc = "Step Over",
    },
    {
      "<leader>dP",
      function() require("dap").pause() end,
      desc = "Pause",
    },
    {
      "<leader>dr",
      function() require("dap").repl.toggle() end,
      desc = "Toggle REPL",
    },
    {
      "<leader>ds",
      function() require("dap").session() end,
      desc = "Session",
    },
    {
      "<leader>dt",
      function() require("dap").terminate() end,
      desc = "Terminate",
    },
    {
      "<leader>dw",
      function() require("dap.ui.widgets").hover() end,
      desc = "Widgets",
    },
    {
      "<leader>du",
      function() require("dapui").toggle() end,
      desc = "Dap UI",
    },
    {
      "<leader>de",
      function() require("dapui").eval() end,
      desc = "Eval",
      mode = { "n", "v" },
    },
  },
}
