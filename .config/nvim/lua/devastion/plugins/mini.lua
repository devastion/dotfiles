local mini_version = "*"

---@type LazySpec
return {
  {
    "echasnovski/mini.icons",
    version = mini_version,
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  {
    "echasnovski/mini.files",
    version = mini_version,
    lazy = true,
    opts = {},
    keys = {
      {
        "<leader>e",
        function() require("mini.files").open() end,
        desc = "File Explorer (root)",
      },
      {
        "<leader>E",
        function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end,
        desc = "File Explorer (cwd)",
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event) Snacks.rename.on_rename_file(event.data.from, event.data.to) end,
      })
    end,
  },
  {
    "echasnovski/mini.pairs",
    version = mini_version,
    event = "InsertEnter",
    opts = {
      modes = { insert = true, command = true, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { "string" },
      skip_unbalanced = true,
      markdown = true,
    },
    config = function(_, opts) require("devastion.utils.plugins").mini_pairs(opts) end,
  },
  {
    "echasnovski/mini.surround",
    version = mini_version,
    lazy = true,
    keys = {
      {
        "sa",
        function() require("mini.surround").add() end,
        desc = "Add Surrounding",
        mode = { "n", "v" },
      },
      {
        "sd",
        function() require("mini.surround").delete() end,
        desc = "Delete Surrounding",
      },
      {
        "sr",
        function() require("mini.surround").replace() end,
        desc = "Replace Surrounding",
      },
    },
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
    "echasnovski/mini.comment",
    version = mini_version,
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
    keys = {
      { "gc", function() require("mini.comment").operator() end, desc = "Comment", expr = true },
      { "gc", function() require("mini.comment").operator() end, desc = "Comment Visual", expr = true, mode = "x" },
      {
        "gc",
        function() require("mini.comment").textobject() end,
        desc = "Comment Text Object",
        expr = true,
        mode = "o",
      },
      { "gcc", function() return require("mini.comment").operator() .. "_" end, desc = "Comment Line", expr = true },
    },
  },
  {
    "echasnovski/mini.splitjoin",
    version = mini_version,
    lazy = true,
    keys = {
      {
        "J",
        function() require("mini.splitjoin").toggle() end,
        desc = "Split/Join",
      },
    },
  },
  {
    "echasnovski/mini.align",
    version = mini_version,
    event = "VeryLazy",
    opts = {},
  },
  {
    "echasnovski/mini.operators",
    version = mini_version,
    lazy = true,
    keys = {
      {
        "sx",
        function() require("mini.operators").exchange() end,
        desc = "Exchange",
        mode = { "n", "v" },
      },
      {
        "ss",
        function() require("mini.operators").replace() end,
        desc = "Replace",
        mode = { "n", "v" },
      },
    },
    opts = function()
      require("mini.operators").make_mappings("replace", { textobject = "ss", line = "", selection = "ss" })
      require("mini.operators").make_mappings("exchange", { textobject = "sx", line = "", selection = "sx" })

      return {
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
      }
    end,
  },
  {
    "echasnovski/mini.indentscope",
    version = mini_version,
    opts = function()
      return {
        draw = {
          animation = require("mini.indentscope").gen_animation.none(),
        },
        options = { try_as_border = true },
      }
    end,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "lazy",
          "mason",
          "notify",
        },
        callback = function() vim.b.miniindentscope_disable = true end,
      })
    end,
  },
  {
    "echasnovski/mini.move",
    version = mini_version,
    event = "VeryLazy",
    opts = {},
  },
}
