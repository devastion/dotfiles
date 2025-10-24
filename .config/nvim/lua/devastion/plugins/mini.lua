local mini_version = "*"

---@type LazySpec
return {
  {
    "echasnovski/mini.icons",
    version = mini_version,
    lazy = true,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  {
    "nvim-mini/mini.files",
    version = mini_version,
    opts = {},
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open()
        end,
        mode = "n",
        desc = "Files (root)",
      },
      {
        "<leader>E",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        mode = "n",
        desc = "Files (root)",
      },
    },
  },
  {
    "nvim-mini/mini.ai",
    event = { "VeryLazy" },
    opts = function()
      local gen_spec = require("mini.ai").gen_spec
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      return {
        n_lines = 500,
        custom_textobjects = {
          o = gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          u = gen_spec.function_call(), -- u for "Usage"
          U = gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
          g = gen_ai_spec.buffer(), -- buffer
          D = gen_ai_spec.diagnostic(),
          I = gen_ai_spec.indent(),
          L = gen_ai_spec.line(),
          N = gen_ai_spec.number(),
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      Devastion.on_load("which-key.nvim", function()
        vim.schedule(function()
          require("devastion.helpers.mini").ai_whichkey(opts)
        end)
      end)
    end,
  },
  {
    "nvim-mini/mini.pairs",
    version = mini_version,
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      modes = { insert = true, command = true, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { "string" },
      skip_unbalanced = true,
      markdown = true,
    },
    config = function(_, opts)
      local pairs = require("mini.pairs")
      pairs.setup(opts)
      local open = pairs.open
      ---@diagnostic disable-next-line: duplicate-set-field
      pairs.open = function(pair, neigh_pattern)
        if vim.fn.getcmdline() ~= "" then
          return open(pair, neigh_pattern)
        end
        local o, c = pair:sub(1, 1), pair:sub(2, 2)
        local line = vim.api.nvim_get_current_line()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local next = line:sub(cursor[2] + 1, cursor[2] + 1)
        local before = line:sub(1, cursor[2])
        if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
          return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
        end
        if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
          return o
        end
        if opts.skip_ts and #opts.skip_ts > 0 then
          local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
          for _, capture in ipairs(ok and captures or {}) do
            if vim.tbl_contains(opts.skip_ts, capture.capture) then
              return o
            end
          end
        end
        if opts.skip_unbalanced and next == c and c ~= o then
          local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
          local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
          if count_close > count_open then
            return o
          end
        end
        return open(pair, neigh_pattern)
      end
    end,
  },
  {
    "nvim-mini/mini.surround",
    version = mini_version,
    event = { "VeryLazy" },
    opts = {
      mappings = {
        add = "sa",
        delete = "sd",
        replace = "sr",
        find = "",
        find_left = "",
        highlight = "",
        update_n_lines = "",
        suffix_last = "",
        suffix_next = "",
      },
      n_lines = 500,
    },
  },
  {
    "nvim-mini/mini.indentscope",
    version = mini_version,
    event = { "VeryLazy" },
    opts = function()
      return {
        draw = {
          animation = require("mini.indentscope").gen_animation.none(),
        },
        options = { try_as_border = true },
      }
    end,
  },
  {
    "nvim-mini/mini.operators",
    version = mini_version,
    event = { "VeryLazy" },
    opts = {
      evaluate = {
        prefix = "",
        func = nil,
      },
      exchange = {
        prefix = "",
        reindent_linewise = true,
      },
      multiply = {
        prefix = "",
        func = nil,
      },
      replace = {
        prefix = "",
        reindent_linewise = true,
      },
      sort = {
        prefix = "",
        func = nil,
      },
    },
    config = function(_, opts)
      local mini_operators = require("mini.operators")
      mini_operators.setup(opts)
      mini_operators.make_mappings("replace", { textobject = "ss", line = "sS", selection = "ss" })
      mini_operators.make_mappings("sort", { textobject = "so", line = "sO", selection = "so" })
      vim.keymap.set({ "n", "x" }, "s", "<Nop>")
    end,
  },
  {
    "nvim-mini/mini.splitjoin",
    version = mini_version,
    event = { "VeryLazy" },
    opts = {
      mappings = { toggle = "J" },
    },
  },
  {
    "nvim-mini/mini.align",
    version = mini_version,
    event = { "VeryLazy" },
    opts = {},
  },
  {
    "nvim-mini/mini.move",
    version = mini_version,
    event = { "VeryLazy" },
    opts = {},
  },
  {
    "nvim-mini/mini.comment",
    version = mini_version,
    dependencies = {
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        lazy = true,
        opts = {
          enable_autocmd = false,
        },
      },
    },
    event = { "VeryLazy" },
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },
  {
    "nvim-mini/mini.extra",
    version = mini_version,
    event = { "VeryLazy" },
    opts = {},
  },
}
