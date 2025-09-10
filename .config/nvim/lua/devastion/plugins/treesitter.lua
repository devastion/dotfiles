---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    opts_extend = { "ensure_installed" },
    ---@class TSConfig
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
    },
    config = function(_, opts)
      local utils = require("devastion.utils.common")
      local ensure_installed = utils.dedup(opts.ensure_installed)
      local ignored = { "tmux" }

      if ensure_installed and #ensure_installed > 0 then
        require("nvim-treesitter").install(ensure_installed)
        -- register and start parsers for filetypes
        for _, parser in ipairs(ensure_installed) do
          local filetypes = parser -- In this case, parser is the filetype/language name
          vim.treesitter.language.register(parser, filetypes)

          vim.api.nvim_create_autocmd({ "FileType" }, {
            pattern = filetypes,
            callback = function(event) vim.treesitter.start(event.buf, parser) end,
          })
        end
      end

      -- Auto-install and start parsers for any buffer
      vim.api.nvim_create_autocmd({ "BufRead" }, {
        callback = function(event)
          local bufnr = event.buf
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

          -- Skip if no filetype
          if filetype == "" then
            return
          end

          -- Check if this filetype is already handled by explicit ensure_installed config
          for _, filetypes in pairs(ensure_installed) do
            local ft_table = type(filetypes) == "table" and filetypes or { filetypes }
            if vim.tbl_contains(ft_table, filetype) then
              return -- Already handled above
            end
          end

          for _, filetypes in pairs(ignored) do
            local ft_table = type(filetypes) == "table" and filetypes or { filetypes }
            if vim.tbl_contains(ft_table, filetype) then
              return -- Already handled above
            end
          end

          -- Get parser name based on filetype
          local parser_name = vim.treesitter.language.get_lang(filetype) -- might return filetype (not helpful)
          if not parser_name then
            return
          end
          -- Try to get existing parser (helpful check if filetype was returned above)
          local parser_configs = require("nvim-treesitter.parsers")
          if not parser_configs[parser_name] then
            return -- Parser not available, skip silently
          end

          local parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

          if not parser_installed then
            -- If not installed, install parser synchronously
            require("nvim-treesitter").install({ parser_name }):wait(30000)
          end

          -- let's check again
          parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

          if parser_installed then
            -- Start treesitter for this buffer
            vim.treesitter.start(bufnr, parser_name)
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = {
      enable_autocmd = true,
      mode = "cursor",
      max_lines = 0,
      multiwindow = true,
    },
    keys = {
      {
        "[c",
        function() require("treesitter-context").go_to_context(vim.v.count1) end,
        desc = "Context",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { { "nvim-treesitter/nvim-treesitter", branch = "main" } },
    branch = "main",
    lazy = false,
    ---@module "nvim-treesitter-textobjects"
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
      local map = require("devastion.utils.common").remap

      -- TODO: Add more
      local text_objects_outer = {
        f = "@function.outer",
        c = "@class.outer",
        p = "@parameter.outer",
        l = "@loop.outer",
        a = "@attribute.outer",
      }
      local text_objects_inner = {
        f = "@function.inner",
        c = "@class.inner",
        p = "@parameter.inner",
        l = "@loop.inner",
        a = "@attribute.inner",
      }

      local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
      local goto_next_start = require("nvim-treesitter-textobjects.move").goto_next_start
      local goto_next_end = require("nvim-treesitter-textobjects.move").goto_next_end
      local goto_previous_start = require("nvim-treesitter-textobjects.move").goto_previous_start
      local goto_previous_end = require("nvim-treesitter-textobjects.move").goto_previous_end

      for k, v in pairs(text_objects_outer) do
        map("a" .. k, function() select_textobject(v, "textobjects") end, "Select " .. v, { "x", "o" })
        map(
          "[" .. k,
          function() goto_previous_start(v, "textobjects") end,
          "Goto Previous Start " .. v,
          { "n", "x", "o" }
        )
        map(
          "[" .. string.upper(k),
          function() goto_previous_end(v, "textobjects") end,
          "Goto Previous End " .. v,
          { "n", "x", "o" }
        )
      end

      for k, v in pairs(text_objects_inner) do
        map("i" .. k, function() select_textobject(v, "textobjects") end, "Select " .. v, { "x", "o" })
        map("]" .. k, function() goto_next_start(v, "textobjects") end, "Goto Next Start " .. v, { "n", "x", "o" })
        map(
          "]" .. string.upper(k),
          function() goto_next_end(v, "textobjects") end,
          "Goto Next End " .. v,
          { "n", "x", "o" }
        )
      end

      map(
        "<C-a><C-n>",
        function() require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner") end,
        "Swap @parameter with next"
      )
      map(
        "<C-a><C-p>",
        function() require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner") end,
        "Swap @parameter with previous"
      )
    end,
  },
  {
    "rrethy/nvim-treesitter-endwise",
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
