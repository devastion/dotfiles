---@type LazySpec
return {
  "nvim-neotest/neotest",
  lazy = true,
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-neotest/neotest-plenary",
    {
      "devastion/neotest-phpunit",
      dev = true,
    },
    {
      "devastion/neotest-node",
      dev = true,
    },
    "diidiiman/neotest-python",
  },
  config = function()
    local dap = require("dap")
    require("neotest").setup({
      adapters = {
        require("neotest-plenary"),
        require("neotest-phpunit")({
          phpunit_cmd = function()
            return vim.g.phpunit_cmd
          end,
          env = {
            XDEBUG_CONFIG = "idekey=neotest",
            XDEBUG_MODE = "coverage",
          },
          dap = dap.configurations.php[1],
          coverage = {
            enabled = true,
            args = "--coverage-cobertura",
            path = "coverage/cobertura.xml",
          },
          docker = {
            enabled = true,
            container_name = "php",
            args = { "exec", "-i", "-w", "/var/www/html" },
            workdir = nil,
          },
        }),
        require("neotest-node"),
        require("neotest-python")({
          dap = { justMyCode = false },
          args = { "--log-level", "INFO", "--color", "yes", "-vv", "-s" },
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
      floating = { border = vim.g.ui_border },
    })

    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          -- Replace newline and tab characters with space for more compact diagnostics
          local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          return message
        end,
      },
    }, neotest_ns)
  end,
  keys = function()
    return {
      {
        "<leader>t",
        "",
        mode = { "n", "v" },
        desc = "+[Testing]",
      },
      {
        "<leader>ta",
        function()
          require("neotest").run.attach()
        end,
        desc = "Attach",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run File",
      },
      {
        "<leader>tF",
        function()
          require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" })
        end,
        desc = "Run File (DAP)",
      },
      {
        "<leader>tt",
        function()
          require("neotest").run.run({ suite = true })
        end,
        desc = "Run All Test Files",
      },
      {
        "<leader>tT",
        function()
          require("neotest").run.run({ suite = true, strategy = "dap" })
        end,
        desc = "Run All Test Files (DAP)",
      },
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest",
      },
      {
        "<leader>tR",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Run Nearest (DAP)",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run Last",
      },
      {
        "<leader>tL",
        function()
          require("neotest").run.run_last({ strategy = "dap" })
        end,
        desc = "Run Last (DAP)",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle Summary",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "Show Output",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle Output Panel",
      },
      {
        "<leader>tS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop",
      },
      {
        "<leader>tw",
        function()
          require("neotest").watch.toggle(vim.fn.expand("%"))
        end,
        desc = "Toggle Watch",
      },
    }
  end,
}
