---@type LazySpec
return {
  {
    "folke/which-key.nvim",
    event = { "VeryLazy" },
    opts = function()
      return {
        preset = "helix",
        delay = 0,
        spec = {
          { "<leader>f", group = "+[Find]" },
          { "<leader>c", group = "+[Code]", mode = { "n", "v" } },
          { "<leader>s", group = "+[Search]", mode = { "n", "v" } },
          { "<leader>g", group = "+[Git]", mode = { "n", "v" } },
          { "<leader>U", group = "+[UI Toggles]", mode = { "n", "v" } },
          { "<leader><tab>", group = "+[Tabs]" },
          { "gr", group = "+[LSP]" },
          { "gc", group = "+[Comment]" },
          { "[", group = "+[Prev]", mode = { "n", "v", "o" } },
          { "]", group = "+[Next]", mode = { "n", "v", "o" } },
          { "g", group = "+[Goto]" },
          { "z", group = "+[Fold]" },
          { "s", group = "+[Surround/Operators]" },
          {
            "<leader>b",
            group = "+[Buffers]",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          {
            "<C-w>",
            group = "+[Windows]",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
        },
        icons = {
          mappings = true,
          keys = {
            Space = "Space",
            Esc = "Esc",
            BS = "Backspace",
            C = "Ctrl-",
          },
        },
        triggers = {
          { "<auto>", mode = "nixsotc" },
          { "s", mode = { "n", "v" } },
        },
        sort = { "order", "group", "alphanum" },
      }
    end,
  },
  {
    "otavioschwanck/arrow.nvim",
    dependencies = { "echasnovski/mini.icons" },
    keys = {
      {
        "m",
        function()
          require("arrow.commands").commands.open()
        end,
        desc = "Arrow",
      },
    },
    opts = {
      always_show_path = true,
      separate_by_branch = true,
      leader_key = "m",
      buffer_leader_key = "M",
      separate_save_and_remove = true,
      per_buffer_config = {
        sort_automatically = false,
      },
    },
  },
  {
    "magicduck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
      {
        "<leader>cR",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace",
      },
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      jump = {
        nohlsearch = true,
        autojump = true,
      },
      modes = {
        search = {
          enabled = true,
        },
        char = {
          jump_labels = true,
          config = function(opts)
            -- autohide flash when in operator-pending mode
            opts.autohide = opts.autohide
              or (
                vim.fn.mode(true):find("no")
                and (vim.v.operator == "y" or vim.v.operator == "d" or vim.v.operator == "g@")
              )

            -- disable jump labels when not enabled, when using a count,
            -- or when recording/executing registers
            opts.jump_labels = opts.jump_labels
              and vim.v.count == 0
              and vim.fn.reg_executing() == ""
              and vim.fn.reg_recording() == ""

            -- Show jump labels only in operator-pending mode
            opts.jump_labels = not vim.fn.mode(true):find("o")
          end,
          keys = { "f", "F", "t", "T" },
          char_actions = function(motion)
            return {
              [motion:lower()] = "next",
              [motion:upper()] = "prev",
            }
          end,
        },
      },
    },
    keys = {
      {
        "<leader><Space>",
        function()
          local Flash = require("flash")

          local function format(opts)
            return {
              { opts.match.label1, "FlashMatch" },
              { opts.match.label2, "FlashLabel" },
            }
          end

          Flash.jump({
            search = { mode = "search" },
            label = { after = false, before = { 0, 0 }, uppercase = false, format = format },
            pattern = [[\<]],
            action = function(match, state)
              state:hide()
              Flash.jump({
                search = { max_length = 0 },
                highlight = { matches = false },
                label = { format = format },
                matcher = function(win)
                  -- limit matches to the current label
                  return vim.tbl_filter(function(m)
                    return m.label == match.label and m.win == win
                  end, state.results)
                end,
                labeler = function(matches)
                  for _, m in ipairs(matches) do
                    m.label = m.label2 -- use the second label
                  end
                end,
              })
            end,
            labeler = function(matches, state)
              local labels = state:labels()
              for m, match in ipairs(matches) do
                match.label1 = labels[math.floor((m - 1) / #labels) + 1]
                match.label2 = labels[(m - 1) % #labels + 1]
                match.label = match.label1
              end
            end,
          })
        end,
        desc = "Flash",
      },
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = function()
      require("which-key").add({ "<leader>r", group = "+[Refactor]", mode = { "n", "x" } })
      require("which-key").add({ "<leader>rb", group = "+[Block]", mode = { "n", "x" } })
      return {
        {
          "<leader>rr",
          function()
            require("refactoring").select_refactor()
          end,
          mode = { "n", "x" },
          desc = "Select Refactor",
        },
        {
          "<leader>re",
          function()
            return require("refactoring").refactor("Extract Function")
          end,
          mode = { "n", "x" },
          expr = true,
          desc = "Extract Function",
        },
        {
          "<leader>rf",
          function()
            return require("refactoring").refactor("Extract Function To File")
          end,
          mode = { "n", "x" },
          expr = true,
          desc = "Extract Function To File",
        },
        {
          "<leader>rv",
          function()
            return require("refactoring").refactor("Extract Variable")
          end,
          mode = { "n", "x" },
          expr = true,
          desc = "Extract Variable",
        },
        {
          "<leader>rI",
          function()
            return require("refactoring").refactor("Inline Function")
          end,
          mode = { "n", "x" },
          expr = true,
          desc = "Inline Function",
        },
        {
          "<leader>ri",
          function()
            return require("refactoring").refactor("Inline Variable")
          end,
          mode = { "n", "x" },
          expr = true,
          desc = "Inline Variable",
        },
        {
          "<leader>rbb",
          function()
            return require("refactoring").refactor("Extract Block")
          end,
          mode = { "n", "x" },
          expr = true,
          desc = "Extract Block",
        },
        {
          "<leader>rbf",
          function()
            return require("refactoring").refactor("Extract Block To File")
          end,
          mode = { "n", "x" },
          expr = true,
          desc = "Extract Block To File",
        },
        {
          "<leader>rp",
          function()
            require("refactoring").debug.print_var()
          end,
          mode = { "x", "n" },
          desc = "Print var",
        },
        {
          "<leader>rP",
          function()
            require("refactoring").debug.printf({ below = false })
          end,
          mode = "n",
          desc = "Print",
        },
        {
          "<leader>rc",
          function()
            require("refactoring").debug.cleanup({})
          end,
          mode = "n",
          desc = "Cleanup",
        },
      }
    end,
  },
}
