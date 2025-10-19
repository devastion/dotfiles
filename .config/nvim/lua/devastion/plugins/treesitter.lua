---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    build = function()
      vim.notify("Updating treesitter parsers...", vim.log.levels.INFO)
      require("nvim-treesitter.install").update(nil, { summary = true })
      vim.notify("Treesitter parsers updated!", vim.log.levels.INFO)
    end,
    lazy = vim.fn.argc(-1) == 0,
    event = { "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    config = function()
      local utils = require("devastion.utils")
      local ensure_installed = {
        "bash",
        "blade",
        "c",
        "cpp",
        "css",
        "diff",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "json5",
        "jsonc",
        "latex",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "norg",
        "php",
        "php_only",
        "phpdoc",
        "printf",
        "python",
        "query",
        "regex",
        "scss",
        "svelte",
        "toml",
        "tsx",
        "typescript",
        "typst",
        "vim",
        "vimdoc",
        "vue",
        "xml",
        "yaml",
      }
      local ignored = { "tmux" }

      local isnt_installed = function(lang)
        return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
      end
      local to_install = vim.tbl_filter(isnt_installed, ensure_installed)
      if #to_install > 0 then
        utils.ts_install(to_install)
      end
      local installed_filetypes =
        vim.iter(ensure_installed):map(vim.treesitter.language.get_filetypes):flatten():totable()

      vim.api.nvim_create_autocmd("FileType", {
        pattern = installed_filetypes,
        callback = function(event)
          vim.treesitter.start(event.buf)
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
        callback = function(event)
          local bufnr = event.buf
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

          if filetype == "" then
            return
          end

          for _, filetypes in pairs(ensure_installed) do
            local ft_table = type(filetypes) == "table" and filetypes or { filetypes }
            if vim.tbl_contains(ft_table, filetype) then
              return
            end
          end

          for _, filetypes in pairs(ignored) do
            local ft_table = type(filetypes) == "table" and filetypes or { filetypes }
            if vim.tbl_contains(ft_table, filetype) then
              return
            end
          end

          local parser_name = vim.treesitter.language.get_lang(filetype)
          if not parser_name then
            return
          end

          local parser_configs = require("nvim-treesitter.parsers")
          if not parser_configs[parser_name] then
            return
          end

          local parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

          if not parser_installed then
            require("nvim-treesitter").install({ parser_name }):wait(30000)
          end

          parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

          if parser_installed then
            vim.treesitter.start(bufnr, parser_name)
            vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    branch = "main",
    event = { "VeryLazy" },
    opts = {
      select = {
        lookahead = true,
      },
      move = {
        set_jumps = true,
      },
      multiwindow = true,
    },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)

      local text_objects_outer = {
        f = "@function.outer",
        c = "@class.outer",
        p = "@parameter.outer",
        l = "@loop.outer",
        a = "@assignment.outer",
        r = "@return.outer",
      }
      local text_objects_inner = {
        f = "@function.inner",
        c = "@class.inner",
        p = "@parameter.inner",
        l = "@loop.inner",
        a = "@assignment.inner",
        r = "@return.inner",
      }

      local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
      local goto_next_start = require("nvim-treesitter-textobjects.move").goto_next_start
      local goto_next_end = require("nvim-treesitter-textobjects.move").goto_next_end
      local goto_previous_start = require("nvim-treesitter-textobjects.move").goto_previous_start
      local goto_previous_end = require("nvim-treesitter-textobjects.move").goto_previous_end

      for k, v in pairs(text_objects_outer) do
        vim.keymap.set({ "x", "o" }, "a" .. k, function()
          select_textobject(v, "textobjects")
        end, { desc = "Select " .. v })
        vim.keymap.set({ "n", "x", "o" }, "[" .. k, function()
          goto_previous_start(v, "textobjects")
        end, { desc = "Goto Previous Start " .. v })
        vim.keymap.set({ "n", "x", "o" }, "[" .. string.upper(k), function()
          goto_previous_end(v, "textobjects")
        end, { desc = "Goto Previous End " .. v })
      end

      for k, v in pairs(text_objects_inner) do
        vim.keymap.set({ "x", "o" }, "i" .. k, function()
          select_textobject(v, "textobjects")
        end, { desc = "Select " .. v })
        vim.keymap.set({ "n", "x", "o" }, "]" .. k, function()
          goto_next_start(v, "textobjects")
        end, { desc = "Goto Next Start " .. v })
        vim.keymap.set({ "n", "x", "o" }, "]" .. string.upper(k), function()
          goto_next_end(v, "textobjects")
        end, { desc = "Goto Next End " .. v })
      end

      vim.keymap.set("n", "<leader>a", function()
        require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
      end, { desc = "Swap @parameter with next" })
      vim.keymap.set("n", "<leader>A", function()
        require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
      end, { desc = "Swap @parameter with previous" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "VeryLazy" },
    opts = {
      enable = true,
      mode = "cursor",
      max_lines = 0,
      multiwindow = true,
    },
  },
  {
    "rrethy/nvim-treesitter-endwise",
    event = { "VeryLazy" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "VeryLazy" },
    opts = {},
  },
}
