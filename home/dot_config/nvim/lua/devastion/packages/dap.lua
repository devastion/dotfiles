local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  "nvim-neotest/nvim-nio",
  "thehamsta/nvim-dap-virtual-text",
  {
    src = "liadoz/nvim-dap-repl-highlights",
    data = {
      config = function()
        require("nvim-dap-repl-highlights").setup()
      end,
    },
  },
  "jbyuki/one-small-step-for-vimkind",
  "mfussenegger/nvim-dap-python",
  "igorlfs/nvim-dap-view",
  {
    src = "mfussenegger/nvim-dap",
    data = {
      config = function()
        local dap = require("dap")
        local vscode = require("dap.ext.vscode")

        local mason_dap = {
          "php-debug-adapter",
          "js-debug-adapter",
          "debugpy",
        }

        require("devastion.utils.pkg").mason_install(mason_dap)

        dap.defaults.fallback.switchbuf = "usevisible,usetab,newtab"

        dap.configurations.lua = {
          {
            type = "nlua",
            request = "attach",
            name = "Attach to running Neovim instance",
          },
        }

        dap.adapters.nlua = function(callback, config)
          callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
        end

        local debugpyPythonPath = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python3"
        require("dap-python").setup(debugpyPythonPath, {})

        dap.adapters.php = {
          type = "executable",
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js",
          },
        }

        dap.configurations.php = {
          {
            log = true,
            type = "php",
            request = "launch",
            name = "Listen for XDebug",
            port = 9003,
            stopOnEntry = false,
            xdebugSettings = {
              max_children = 512,
              max_data = 1024,
              max_depth = 4,
            },
            breakpoints = {
              exception = {
                Notice = false,
                Warning = false,
                Error = false,
                Exception = false,
                ["*"] = false,
              },
            },
            pathMappings = {
              ["/var/www/html"] = "${workspaceFolder}",
            },
          },
          {
            log = true,
            type = "php",
            request = "launch",
            name = "Launch currently open file",
            port = 9003,
            stopOnEntry = false,
            program = "${file}",
            cwd = "${fileDirname}",
            xdebugSettings = {
              max_children = 512,
              max_data = 1024,
              max_depth = 4,
            },
            breakpoints = {
              exception = {
                Notice = false,
                Warning = false,
                Error = false,
                Exception = false,
                ["*"] = false,
              },
            },
          },
        }

        for _, adapterType in ipairs({ "node", "chrome", "msedge" }) do
          local pwaType = "pwa-" .. adapterType

          if not dap.adapters[pwaType] then
            dap.adapters[pwaType] = {
              type = "server",
              host = "localhost",
              port = "${port}",
              executable = {
                command = "js-debug-adapter",
                args = { "${port}" },
              },
            }
          end

          -- Define adapters without the "pwa-" prefix for VSCode compatibility
          if not dap.adapters[adapterType] then
            dap.adapters[adapterType] = function(cb, config)
              local nativeAdapter = dap.adapters[pwaType]

              config.type = pwaType

              if type(nativeAdapter) == "function" then
                nativeAdapter(cb, config)
              else
                cb(nativeAdapter)
              end
            end
          end
        end

        local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

        vscode.type_to_filetypes["node"] = js_filetypes
        vscode.type_to_filetypes["pwa-node"] = js_filetypes

        for _, language in ipairs(js_filetypes) do
          if not dap.configurations[language] then
            local runtimeExecutable = nil
            if language:find("typescript") then
              runtimeExecutable = vim.fn.executable("tsx") == 1 and "tsx" or "ts-node"
            end
            dap.configurations[language] = {
              {
                type = "pwa-node",
                request = "launch",
                name = "Launch file",
                program = "${file}",
                cwd = "${workspaceFolder}",
                sourceMaps = true,
                runtimeExecutable = runtimeExecutable,
                skipFiles = {
                  "<node_internals>/**",
                  "node_modules/**",
                },
                resolveSourceMapLocations = {
                  "${workspaceFolder}/**",
                  "!**/node_modules/**",
                },
              },
              {
                type = "pwa-node",
                request = "attach",
                name = "Attach",
                processId = require("dap.utils").pick_process,
                cwd = "${workspaceFolder}",
                sourceMaps = true,
                runtimeExecutable = runtimeExecutable,
                skipFiles = {
                  "<node_internals>/**",
                  "node_modules/**",
                },
                resolveSourceMapLocations = {
                  "${workspaceFolder}/**",
                  "!**/node_modules/**",
                },
              },
            }
          end
        end

        require("dap-view").setup({
          auto_toggle = true,
        })
        require("nvim-dap-virtual-text").setup({})

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

        local json = require("plenary.json")

        ---@diagnostic disable-next-line: duplicate-set-field
        vscode.json_decode = function(str)
          return vim.json.decode(json.json_strip_comments(str))
        end

        ---@param config {type?:string, args?:string[]|fun():string[]?}
        local function dap_get_args(config)
          local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
          local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

          config = vim.deepcopy(config)
          ---@cast args string[]
          config.args = function()
            local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
            if config.type and config.type == "java" then
              ---@diagnostic disable-next-line: return-type-mismatch
              return new_args
            end
            return require("dap.utils").splitstr(new_args)
          end
          return config
        end

        require("which-key").add({
          {
            "<leader>d",
            group = "+[Debug]",
            mode = { "n", "v" },
          },
        })
        map("<leader>db", function()
          require("dap").toggle_breakpoint()
        end, "Toggle Breakpoint")

        map("<leader>dB", function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, "Breakpoint Condition")

        map("<leader>dX", function()
          require("dap").clear_breakpoints()
        end, "Clear Breakpoints")

        map("<leader>dc", function()
          require("dap").continue()
        end, "Run/Continue")

        map("<leader>da", function()
          require("dap").continue({ before = dap_get_args })
        end, "Run with Args")

        map("<leader>dC", function()
          require("dap").run_to_cursor()
        end, "Run to Cursor")

        map("<leader>dg", function()
          require("dap").goto_()
        end, "Go to Line (No Execute)")

        map("<leader>di", function()
          require("dap").step_into()
        end, "Step Into")

        map("<leader>do", function()
          require("dap").step_out()
        end, "Step Out")

        map("<leader>dO", function()
          require("dap").step_over()
        end, "Step Over")

        map("<leader>dj", function()
          require("dap").down()
        end, "Down")

        map("<leader>dk", function()
          require("dap").up()
        end, "Up")

        map("<leader>dl", function()
          require("dap").run_last()
        end, "Run Last")

        map("<leader>dP", function()
          require("dap").pause()
        end, "Pause")

        map("<leader>dr", function()
          require("dap").repl.toggle()
        end, "Toggle REPL")

        map("<leader>dS", function()
          require("dap").session()
        end, "Session")

        map("<leader>dt", function()
          require("dap").terminate()
        end, "Terminate")

        map("<leader>dw", function()
          require("dap.ui.widgets").hover()
        end, "Widgets")

        map("<leader>df", function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.frames)
        end, "Frames")

        map("<leader>du", function()
          require("dap-view").toggle()
        end, "Dap View")

        map("<leader>de", function()
          require("dap-view").add_expr()
        end, "Dap View Add Expresion", { "n", "x" })
      end,
    },
  },
})
