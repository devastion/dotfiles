local pkg = require("devastion.utils.pkg")
local map = require("devastion.utils").map
local autocmd = require("devastion.utils").autocmd

pkg.later(function()
  pkg.add({
    "nvim-neotest/nvim-nio",
    "nvim-neotest/neotest-plenary",
    {
      src = "devastion/neotest-phpunit",
      version = "feat/add-docker-and-coverage-support",
      data = {
        dev = "~/Projects/github/neovim-plugins/neotest-phpunit",
      },
    },
    "devastion/neotest-node",
    "diidiiman/neotest-python",
    {
      src = "nvim-neotest/neotest",
      data = {
        config = function()
          local dap = require("dap")
          require("neotest").setup({
            adapters = {
              require("neotest-plenary"),
              require("neotest-phpunit")({
                filter_dirs = {
                  "vendor",
                  "node_modules",
                  ".git",
                },
                env = {
                  XDEBUG_CONFIG = "idekey=neovim",
                  XDEBUG_MODE = "coverage",
                },
                dap = dap.configurations.php[1],
                docker = {
                  enabled = true,
                },
                coverage = {
                  enabled = true,
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
            floating = { border = vim.g.border_style },
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

          require("which-key").add({
            { "<leader>t", group = "+[Testing]" },
            { "<leader>t]", group = "+[Next]" },
            { "<leader>t[", group = "+[Prev]" },
          })

          map("<leader>ta", function()
            require("neotest").run.attach()
          end, "Attach")

          map("<leader>tf", function()
            require("neotest").run.run(vim.fn.expand("%"))
          end, "Run File")

          map("<leader>tF", function()
            require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" })
          end, "Run File (DAP)")

          map("<leader>tt", function()
            require("neotest").run.run({ suite = true })
          end, "Run All Test Files")

          map("<leader>tT", function()
            require("neotest").run.run({ suite = true, strategy = "dap" })
          end, "Run All Test Files (DAP)")

          map("<leader>tr", function()
            require("neotest").run.run()
          end, "Run Nearest")

          map("<leader>tR", function()
            require("neotest").run.run({ strategy = "dap" })
          end, "Run Nearest (DAP)")

          map("<leader>tl", function()
            require("neotest").run.run_last()
          end, "Run Last")

          map("<leader>tL", function()
            require("neotest").run.run_last({ strategy = "dap" })
          end, "Run Last (DAP)")

          map("<leader>ts", function()
            require("neotest").summary.toggle()
          end, "Toggle Summary")

          map("<leader>to", function()
            require("neotest").output.open({ enter = true, auto_close = true })
          end, "Show Output")

          map("<leader>tO", function()
            require("neotest").output_panel.toggle()
          end, "Toggle Output Panel")

          map("<leader>tS", function()
            require("neotest").run.stop()
          end, "Stop")

          map("<leader>tw", function()
            require("neotest").watch.toggle(vim.fn.expand("%"))
          end, "Toggle Watch")

          local test_statuses = {
            p = "passed",
            s = "skipped",
            f = "failed",
          }

          for key, status in pairs(test_statuses) do
            map("<leader>t]" .. key, function()
              require("neotest").jump.next({ status = status })
            end, status:sub(1, 1):upper() .. status:sub(2) .. " Test")
            map("<leader>t[" .. key, function()
              require("neotest").jump.prev({ status = status })
            end, status:sub(1, 1):upper() .. status:sub(2) .. " Test")
          end

          map("]t", function()
            require("neotest").jump.next()
          end, "Next Test")
          map("[t", function()
            require("neotest").jump.prev()
          end, "Prev Test")
        end,
      },
    },
    {
      -- TODO: Replace with https://github.com/mr-u0b0dy/crazy-coverage.nvim when it supports more langs
      src = "andythigpen/nvim-coverage",
      data = {
        event = { "FileType" },
        pattern = { "php", "typescript", "python" },
        task = function()
          vim.system({ "luarocks", "install", "--lua-version", "5.1", "lua-xmlreader" })
        end,
        config = function()
          require("coverage").setup({
            auto_reload = true,
            load_coverage_cb = function(ftype)
              vim.notify("Loaded " .. ftype .. " coverage", vim.log.levels.INFO)
            end,
            highlights = {
              covered = { fg = "#449dab" },
              uncovered = { fg = "#914c54" },
            },
          })

          local coverage_prefix = "<leader>tc"

          require("which-key").add({
            {
              coverage_prefix,
              group = "+[Coverage]",
              mode = { "n" },
            },
          })

          map(coverage_prefix .. "l", function()
            require("coverage").load(true)
          end, "Load Coverage")
          map(coverage_prefix .. "L", function()
            require("coverage").clear()
          end, "Clear Coverage")
          map(coverage_prefix .. "t", function()
            require("coverage").toggle()
          end, "Toggle Coverage")
          map(coverage_prefix .. "s", function()
            require("coverage").summary()
          end, "Show Coverage Summary")

          local autoload_group = vim.api.nvim_create_augroup("user_coverage_autoload", { clear = false })
          map(coverage_prefix .. "A", function()
            local existing = vim.api.nvim_get_autocmds({ group = "user_coverage_autoload" })
            if #existing > 0 then
              vim.api.nvim_clear_autocmds({ group = "user_coverage_autoload" })
              vim.notify("Coverage autoload autocmd disabled", vim.log.levels.INFO)
            else
              autocmd("BufEnter", {
                desc = "Load automatically nvim-coverage",
                group = autoload_group,
                pattern = { "*.php", "*.py", "*.ts" },
                callback = function()
                  vim.schedule(function()
                    require("coverage").load(true)
                  end)
                end,
              })
              vim.notify("Coverage autoload autocmd enabled", vim.log.levels.INFO)
            end
          end, "Toggle Coverage Autoload Autocmd")
        end,
      },
    },
  })
end)
