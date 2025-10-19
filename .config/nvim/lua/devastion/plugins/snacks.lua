---@type LazySpec
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    quickfile = { enabled = true },
    terminal = {
      win = { style = "float" },
    },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    picker = { enabled = false },
    notifier = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
  },
  keys = {
    {
      "]]",
      function()
        require("snacks.words").jump(vim.v.count1, false)
      end,
      desc = "Next Word Reference",
    },
    {
      "[[",
      function()
        require("snacks.words").jump(-vim.v.count1, false)
      end,
      desc = "Prev Word Reference",
    },
    {
      "grN",
      function()
        require("snacks.rename").rename_file()
      end,
      desc = "Rename File",
    },
    {
      "<leader>go",
      function()
        require("snacks.gitbrowse").open()
      end,
      desc = "Open File in Repository",
    },
    {
      "<C-_>",
      function()
        require("snacks.terminal").toggle()
      end,
      desc = "Toggle Terminal",
      mode = { "n", "t" },
    },
    {
      "<C-/>",
      function()
        require("snacks.terminal").toggle()
      end,
      desc = "Toggle Terminal",
      mode = { "n", "t" },
    },
    {
      "<C-n>",
      function()
        require("snacks.words").jump(vim.v.count1, false)
      end,
      desc = "Next Word Reference",
      mode = "i",
    },
    {
      "<C-p>",
      function()
        require("snacks.words").jump(-vim.v.count1, false)
      end,
      desc = "Prev Word Reference",
      mode = "i",
    },
    {
      "<leader>gg",
      function()
        Snacks.lazygit({ cwd = require("devastion.utils").get_root_directory() })
      end,
      desc = "Lazygit (root)",
    },
    {
      "<leader>gG",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit (cwd)",
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesActionRename",
      callback = function(event)
        require("snacks.rename").on_rename_file(event.data.from, event.data.to)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end

        -- Override print to use snacks for `:=` command
        if vim.fn.has("nvim-0.11") == 1 then
          vim._print = function(_, ...)
            dd(...)
          end
        else
          vim.print = _G.dd
        end

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
