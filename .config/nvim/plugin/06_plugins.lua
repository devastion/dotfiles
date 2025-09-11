local path_package = vim.fn.stdpath("data") .. "/site"
local mini_path = path_package .. "/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "--branch",
    "stable",
    "https://github.com/nvim-mini/mini.nvim",
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

require("mini.deps").setup({ path = { package = path_package } })

MiniDeps.now(function()
  MiniDeps.add({ source = "folke/tokyonight.nvim" })

  vim.api.nvim_cmd({
    cmd = "colorscheme",
    args = { "tokyonight-night" },
  }, {})
end)

MiniDeps.now(function()
  require("mini.icons").setup()
  MiniDeps.later(require("mini.icons").mock_nvim_web_devicons)
  MiniDeps.later(require("mini.icons").tweak_lsp_kind)
end)

MiniDeps.now(function()
  MiniDeps.add({ source = "rmagatti/auto-session" })

  require("auto-session").setup({
    bypass_save_filetypes = { "gitcommit" },
    close_filetypes_on_save = { "checkhealth", "help" },
    git_use_branch_name = true,
    git_auto_restore_on_branch_change = true,
  })
end)

MiniDeps.now(function()
  MiniDeps.add({
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "main",
    hooks = { post_checkout = function() vim.cmd("TSUpdate") end },
  })

  local ensure_installed = {
    "bash",
    "c",
    "diff",
    "git_config",
    "gitattributes",
    "gitcommit",
    "git_rebase",
    "gitignore",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "printf",
    "python",
    "query",
    "regex",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
  }

  local ignored = { "tmux" }

  require("nvim-treesitter").install(ensure_installed)
  local installed_filetypes = vim.iter(ensure_installed):map(vim.treesitter.language.get_filetypes):flatten():totable()

  vim.api.nvim_create_autocmd("FileType", {
    pattern = installed_filetypes,
    callback = function(event) vim.treesitter.start(event.buf) end,
  })

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

  local now_if_args = vim.fn.argc(-1) > 0 and MiniDeps.now or MiniDeps.later
  now_if_args(function()
    MiniDeps.add({
      source = "nvim-treesitter/nvim-treesitter-textobjects",
      checkout = "main",
    })

    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
      },
      move = {
        set_jumps = true,
      },
      multiwindow = true,
    })
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
      vim.keymap.set(
        { "x", "o" },
        "a" .. k,
        function() select_textobject(v, "textobjects") end,
        { desc = "Select " .. v }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "[" .. k,
        function() goto_previous_start(v, "textobjects") end,
        { desc = "Goto Previous Start " .. v }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "[" .. string.upper(k),
        function() goto_previous_end(v, "textobjects") end,
        { desc = "Goto Previous End " .. v }
      )
    end

    for k, v in pairs(text_objects_inner) do
      vim.keymap.set(
        { "x", "o" },
        "i" .. k,
        function() select_textobject(v, "textobjects") end,
        { desc = "Select " .. v }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "]" .. k,
        function() goto_next_start(v, "textobjects") end,
        { desc = "Goto Next Start " .. v }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "]" .. string.upper(k),
        function() goto_next_end(v, "textobjects") end,
        { desc = "Goto Next End " .. v }
      )
    end

    vim.keymap.set(
      "n",
      "<C-a><C-n>",
      function() require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner") end,
      { desc = "Swap @parameter with next" }
    )
    vim.keymap.set(
      "n",
      "<C-a><C-p>",
      function() require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner") end,
      { desc = "Swap @parameter with previous" }
    )

    MiniDeps.add({
      source = "nvim-treesitter/nvim-treesitter-context",
    })
    require("treesitter-context").setup({
      enable = true,
      mode = "cursor",
      max_lines = 0,
      multiwindow = true,
    })
    vim.keymap.set(
      "n",
      "[c",
      function() require("treesitter-context").go_to_context(vim.v.count1) end,
      { desc = "Context" }
    )

    MiniDeps.add({
      source = "rrethy/nvim-treesitter-endwise",
    })
  end)
end)
