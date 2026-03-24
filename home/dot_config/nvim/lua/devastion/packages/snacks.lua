local map = require("devastion.utils").map
local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup

require("devastion.utils.pkg").add({
  {
    src = "folke/snacks.nvim",
    data = {
      init = function()
        autocmd("User", {
          group = augroup("snacks_rename"),
          pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
          callback = function(event)
            require("snacks.rename").on_rename_file(event.data.from, event.data.to)
          end,
        })

        -- selene: allow(global_usage)
        _G.dd = function(...)
          require("snacks").debug.inspect(...)
        end

        -- selene: allow(global_usage)
        _G.bt = function()
          require("snacks").debug.backtrace()
        end
      end,
      config = function()
        require("snacks").setup({
          bigfile = { enabled = false },
          dashboard = { enabled = false },
          explorer = { enabled = false },
          indent = { enabled = false },
          picker = { enabled = false },
          notifier = { enabled = false },
          quickfile = { enabled = false },
          scope = { enabled = false },
          scroll = { enabled = false },
          input = { enabled = true },
          statuscolumn = { enabled = true },
          words = { enabled = true },
          terminal = {
            win = {
              style = "float",
              border = vim.g.border_style,
            },
          },
        })

        map("]]", function()
          require("snacks.words").jump(vim.v.count1, false)
        end, "Next Word Reference")
        map("[[", function()
          require("snacks.words").jump(-vim.v.count1, false)
        end, "Prev Word Reference")
        map("<c-n>", function()
          require("snacks.words").jump(vim.v.count1, false)
        end, "Next Word Reference", "i")
        map("<c-p>", function()
          require("snacks.words").jump(-vim.v.count1, false)
        end, "Prev Word Reference", "i")

        map("grN", function()
          require("snacks.rename").rename_file({
            on_rename = function(to, from)
              require("warp").on_file_update(from, to)
            end,
          })
        end, "Rename File")

        map("<leader>go", function()
          require("snacks.gitbrowse").open()
        end, "Open File in Repository")
        map("<leader>gg", function()
          require("snacks").lazygit()
        end, "LazyGit")

        map("<c-_>", function()
          require("snacks.terminal").toggle()
        end, "Toggle Terminal", { "n", "t" })
        map("<c-/>", function()
          require("snacks.terminal").toggle()
        end, "Toggle Terminal", { "n", "t" })

        map("<leader>bd", function()
          require("snacks").bufdelete()
        end, "Delete Buffer")
        map("<leader>bo", function()
          require("snacks").bufdelete.other()
        end, "Delete Other Buffers")
        map("<leader>bO", function()
          require("snacks").bufdelete.all()
        end, "Delete All Buffers")

        require("snacks.keymap").set({ "n", "x" }, "<localleader>r", function()
          require("snacks").debug.run()
        end, {
          desc = "Run lua",
          ft = "lua",
        })
        require("snacks.keymap").set("n", "<localleader>s", function()
          require("snacks").scratch()
        end, {
          desc = "Scratch",
          ft = "lua",
          buffer = true,
        })
      end,
    },
  },
})
