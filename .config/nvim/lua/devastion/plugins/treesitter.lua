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

      local isnt_installed = function(lang)
        return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
      end
      local to_install = vim.tbl_filter(isnt_installed, vim.g.treesitter_ensure_installed)
      if #to_install > 0 then
        utils.ts_install(to_install)
      end
      local installed_filetypes =
        vim.iter(vim.g.treesitter_ensure_installed):map(vim.treesitter.language.get_filetypes):flatten():totable()

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

          for _, filetypes in pairs(vim.g.treesitter_ensure_installed) do
            local ft_table = type(filetypes) == "table" and filetypes or { filetypes }
            if vim.tbl_contains(ft_table, filetype) then
              return
            end
          end

          for _, filetypes in pairs(vim.g.treesitter_ignored) do
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
    branch = "main",
    event = "VeryLazy",
    opts = {
      move = {
        enable = true,
        set_jumps = true,
        keys = {
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]a"] = "@parameter.inner",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
            ["]A"] = "@parameter.inner",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.inner",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[A"] = "@parameter.inner",
          },
        },
      },
    },
    config = function(_, opts)
      local TS = require("nvim-treesitter-textobjects")
      TS.setup(opts)

      local function attach(buf)
        ---@type table<string, table<string, string>>
        local moves = vim.tbl_get(opts, "move", "keys") or {}

        for method, keymaps in pairs(moves) do
          for key, query in pairs(keymaps) do
            local desc = query:gsub("@", ""):gsub("%..*", "")
            desc = desc:sub(1, 1):upper() .. desc:sub(2)
            desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
            desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
            if not (vim.wo.diff and key:find("[cC]")) then
              vim.keymap.set({ "n", "x", "o" }, key, function()
                require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
              end, {
                buffer = buf,
                desc = desc,
                silent = true,
              })
            end
          end
        end
        vim.keymap.set("n", "<leader>a", function()
          require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
        end, { desc = "Swap @parameter with next", buffer = buf })
        vim.keymap.set("n", "<leader>A", function()
          require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
        end, { desc = "Swap @parameter with previous", buffer = buf })
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_treesitter_textobjects", { clear = true }),
        callback = function(ev)
          attach(ev.buf)
        end,
      })
      vim.tbl_map(attach, vim.api.nvim_list_bufs())
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
      },
    },
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
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
      },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
      },
    },
    event = { "VeryLazy" },
    opts = {},
  },
  {
    "andersevenrud/nvim_context_vt",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
      },
    },
    event = { "VeryLazy" },
    opts = {
      prefix = "",
      min_rows = 10,
    },
  },
}
