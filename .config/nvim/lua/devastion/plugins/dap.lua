vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/thehamsta/nvim-dap-virtual-text",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/nvim-lua/plenary.nvim",
}, { confirm = false })

local dap = require("dap")
local dapui = require("dapui")

require("nvim-dap-virtual-text").setup({})

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
local json = require("plenary.json")
local vscode = require("dap.ext.vscode")

---@diagnostic disable-next-line: duplicate-set-field
vscode.json_decode = function(str) return vim.json.decode(json.json_strip_comments(str)) end

require("which-key").add({ "<leader>d", group = "+[Debugger]", mode = { "n", "v" } })
vim.keymap.set(
  "n",
  "<leader>dB",
  function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
  { desc = "Breakpoint Condition" }
)

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Run/Continue" })
vim.keymap.set(
  "n",
  "<leader>da",
  function() dap.continue({ before = require("devastion.utils").dap_get_args }) end,
  { desc = "Run with Args" }
)
vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "Run to Cursor" })
vim.keymap.set("n", "<leader>dg", dap.goto_, { desc = "Go to Line (No Execute)" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
vim.keymap.set("n", "<leader>dj", dap.down, { desc = "Down" })
vim.keymap.set("n", "<leader>dk", dap.up, { desc = "Up" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step Out" })
vim.keymap.set("n", "<leader>dO", dap.step_over, { desc = "Step Over" })
vim.keymap.set("n", "<leader>dP", dap.pause, { desc = "Pause" })
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>ds", dap.session, { desc = "Session" })
vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
vim.keymap.set("n", "<leader>dw", require("dap.ui.widgets").hover, { desc = "Widgets" })
vim.keymap.set("n", "<leader>df", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.frames)
end, { desc = "Frames" })
vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Dap UI" })
vim.keymap.set({ "n", "v" }, "<leader>de", dapui.eval, { desc = "Eval" })
