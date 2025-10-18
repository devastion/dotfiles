vim.pack.add({
  "https://github.com/nvim-neotest/neotest",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/nvim-lua/plenary.nvim",
  { src = "https://github.com/devastion/neotest-phpunit", version = "autodetect-docker-command" },
  "https://github.com/devastion/neotest-node",
  -- TODO: Use main repo when merged
  "https://github.com/diidiiman/neotest-python",
}, { confirm = false })

require("neotest").setup({
  adapters = {
    require("neotest-phpunit")({
      phpunit_cmd = function() return "dphpunit" end,
      env = {
        XDEBUG_CONFIG = "idekey=neotest",
      },
    }),
    require("neotest-node"),
    require("neotest-python")({
      dap = { justMyCode = false },
      runner = "pytest",
      docker = {
        container = "python-container",
        args = { "-i", "-w", "/app" },
        workdir = "/app",
      },
    }),
  },
  status = { virtual_text = true },
  output = { open_on_run = true },
})

require("which-key").add({ "<leader>t", group = "+[Testing]", mode = { "n", "v" } })
vim.keymap.set("n", "<leader>ta", function() require("neotest").run.attach() end, { desc = "Attach" })
vim.keymap.set("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run File" })
vim.keymap.set(
  "n",
  "<leader>tF",
  function() require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" }) end,
  { desc = "Run with (DAP)" }
)
vim.keymap.set(
  "n",
  "<leader>tt",
  function() require("neotest").run.run({ suite = true }) end,
  { desc = "Run All Test Files" }
)
vim.keymap.set(
  "n",
  "<leader>tT",
  function() require("neotest").run.run({ suite = true, strategy = "dap" }) end,
  { desc = "Run All Test Files (DAP)" }
)
vim.keymap.set("n", "<leader>tr", function() require("neotest").run.run() end, { desc = "Run Nearest" })
vim.keymap.set(
  "n",
  "<leader>tR",
  function() require("neotest").run.run({ strategy = "dap" }) end,
  { desc = "Run Nearest (DAP)" }
)
vim.keymap.set("n", "<leader>tl", function() require("neotest").run.run_last() end, { desc = "Run Last" })
vim.keymap.set(
  "n",
  "<leader>tL",
  function() require("neotest").run.run_last({ strategy = "dap" }) end,
  { desc = "Run Last (DAP)" }
)
vim.keymap.set("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Toggle Summary" })
vim.keymap.set(
  "n",
  "<leader>to",
  function() require("neotest").output.open({ enter = true }) end,
  { desc = "Show Output" }
)
vim.keymap.set(
  "n",
  "<leader>tO",
  function() require("neotest").output_panel.toggle() end,
  { desc = "Toggle Output Panel" }
)
vim.keymap.set("n", "<leader>tS", function() require("neotest").run.stop() end, { desc = "Stop" })
vim.keymap.set(
  "n",
  "<leader>tw",
  function() require("neotest").watch.toggle(vim.fn.expand("%")) end,
  { desc = "Toggle Watch" }
)
