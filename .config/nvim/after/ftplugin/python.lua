vim.pack.add({ "https://github.com/mfussenegger/nvim-dap-python" }, { confirm = false })

vim.cmd.packadd("venv-selector.nvim")
require("venv-selector").setup({
  options = {
    notify_user_on_venv_activation = true,
  },
})

vim.g.ts_install({ "python", "xml" })
vim.g.mason_install({ "basedpyright", "debugpy" })

local mason_path = vim.fn.stdpath("data") .. "/mason/"
local debugpy_adapter_path = mason_path .. "packages/debugpy/venv/bin/debugpy-adapter"
require("dap-python").setup(debugpy_adapter_path)

local map = require("devastion.utils").remap

map("<leader>cv", "<cmd>:VenvSelect<cr>", "Select VirtualEnv", "n", { buffer = true })

require("which-key").add({ "<leader>dP", group = "+[Python]", mode = { "n" } })
map("<leader>dPt", function() require("dap-python").test_method() end, "Debug Method", "n", { buffer = true })
map("<leader>dPc", function() require("dap-python").test_class() end, "Debug Class", "n", { buffer = true })
