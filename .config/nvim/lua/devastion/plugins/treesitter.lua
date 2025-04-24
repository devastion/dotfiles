---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    event = { "BufReadPost", "BufWritePost", "BufNewFile", "VeryLazy" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "rrethy/nvim-treesitter-endwise",
    },
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "ruby",
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "diff",
        "regex",
      },
      auto_install = true,
      highlight = {
        enable = true,
        disable = { "tmux" },
        additional_vim_regex_highlighting = { "ruby" },
      },
      indent = { enable = true, disable = { "ruby" } },
      endwise = { enable = true },
      textobjects = {
        swap = {
          enable = true,
          swap_next = {
            ["<C-a><C-n>"] = "@parameter.inner",
          },
          swap_previous = {
            ["<C-a><C-p>"] = "@parameter.inner",
          },
        },
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            ["ac"] = "@conditional.outer",
            ["ic"] = "@conditional.inner",
            ["ap"] = "@parameter.outer",
            ["ip"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        opts.ensure_installed = require("devastion.utils.common").dedup(opts.ensure_installed)
      end
      require("nvim-treesitter.configs").setup(opts)
    end,
    keys = {
      {
        ";",
        function() require("nvim-treesitter.textobjects.repeatable_move").repeat_last_move_next() end,
        desc = "Repeat Last Move Next",
        mode = { "n", "x", "o" },
      },
      {
        ",",
        function() require("nvim-treesitter.textobjects.repeatable_move").repeat_last_move_previous() end,
        desc = "Repeat Last Move Previous",
        mode = { "n", "x", "o" },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = { mode = "cursor", max_lines = 0 },
    keys = {
      {
        "[c",
        function() require("treesitter-context").go_to_context(vim.v.count1) end,
        desc = "Context",
      },
    },
  },
  {
    "chrisgrieser/nvim-various-textobjs",
    lazy = true,
    opts = {
      keymaps = {
        useDefaults = false,
      },
    },
    keys = {
      {
        "ae",
        function() require("various-textobjs").subword("outer") end,
        mode = { "o", "x" },
        desc = "Subword (outer)",
      },
      {
        "ie",
        function() require("various-textobjs").subword("inner") end,
        mode = { "o", "x" },
        desc = "Subword (inner)",
      },
      {
        "a_",
        function() require("various-textobjs").lineCharacterwise("outer") end,
        mode = { "o", "x" },
        desc = "Current Line (including whitespaces)",
      },
      {
        "i_",
        function() require("various-textobjs").lineCharacterwise("inner") end,
        mode = { "o", "x" },
        desc = "Curren Line (without whitespaces)",
      },
      {
        "av",
        function() require("various-textobjs").value("outer") end,
        mode = { "o", "x" },
        desc = "Value (from key-value)",
      },
      {
        "iv",
        function() require("various-textobjs").value("inner") end,
        mode = { "o", "x" },
        desc = "Value (from key-value)",
      },
      {
        "ak",
        function() require("various-textobjs").key("outer") end,
        mode = { "o", "x" },
        desc = "Key (from key-value)",
      },
      {
        "ik",
        function() require("various-textobjs").key("inner") end,
        mode = { "o", "x" },
        desc = "Key (from key-value)",
      },
      {
        "ad",
        function() require("various-textobjs").diagnostic() end,
        mode = { "o", "x" },
        desc = "Subword (inner)",
      },
      {
        "i`",
        function() require("various-textobjs").mdFencedCodeBlock("inner") end,
        mode = { "o", "x" },
        ft = "markdown",
        desc = "Fenced Code Block (inner)",
      },
      {
        "a`",
        function() require("various-textobjs").mdFencedCodeBlock("outer") end,
        mode = { "o", "x" },
        ft = "markdown",
        desc = "Fenced Code Block (outer)",
      },
      {
        "a<cr>",
        function() require("various-textobjs").entireBuffer() end,
        mode = { "o", "x" },
        desc = "Entire File",
      },
      {
        "gx",
        function()
          -- select URL
          require("various-textobjs").url()

          -- plugin only switches to visual mode when textobj is found
          local foundURL = vim.fn.mode() == "v"
          if not foundURL then
            return
          end

          -- retrieve URL with the z-register as intermediary
          vim.cmd.normal({ '"zy', bang = true })
          local url = vim.fn.getreg("z")
          vim.ui.open(url) -- requires nvim 0.10
        end,
        mode = { "n" },
        desc = "URL Opener",
      },
      {
        "sD",
        function()
          -- select outer indentation
          require("various-textobjs").indentation("outer", "outer")

          -- plugin only switches to visual mode when a textobj has been found
          local indentationFound = vim.fn.mode():find("V")
          if not indentationFound then
            return
          end

          -- dedent indentation
          vim.cmd.normal({ "<", bang = true })

          -- delete surrounding lines
          local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1]
          local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1]
          vim.cmd(tostring(endBorderLn) .. " delete") -- delete end first so line index is not shifted
          vim.cmd(tostring(startBorderLn) .. " delete")
        end,
        desc = "Delete Surrounding Indentation",
      },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = {},
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },
}
