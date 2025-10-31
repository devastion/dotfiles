---@type LazySpec
return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  opts = function()
    local fzf = require("fzf-lua")
    local actions = fzf.actions
    return {
      "hide",
      keymap = {
        builtin = {
          ["<c-f>"] = "preview-page-down",
          ["<c-b>"] = "preview-page-up",
        },
        fzf = {
          ["ctrl-q"] = "select-all+accept",
          ["ctrl-u"] = "half-page-up",
          ["ctrl-d"] = "half-page-down",
          ["ctrl-x"] = "jump",
          ["ctrl-f"] = "preview-page-down",
          ["ctrl-b"] = "preview-page-up",
        },
      },
      fzf_colors = true,
      fzf_opts = { ["--no-scrollbar"] = true },
      defaults = { formatter = "path.dirname_first" },
      winopts = {
        width = 0.8,
        height = 0.8,
        row = 0.5,
        col = 0.5,
        preview = {
          default = "bat_native",
          scrollchars = { "┃", "" },
          wrap = true,
        },
      },
      files = {
        cwd_prompt = false,
        actions = {
          ["alt-i"] = { actions.toggle_ignore },
          ["alt-h"] = { actions.toggle_hidden },
        },
      },
      grep = { actions = { ["alt-i"] = { actions.toggle_ignore }, ["alt-h"] = { actions.toggle_hidden } } },
      lsp = { code_actions = { previewer = "codeaction_native" } },
      oldfiles = { cwd_only = true, include_current_session = true, winopts = { preview = { hidden = true } } },
    }
  end,
  config = function(_, opts)
    require("fzf-lua").setup(opts)
  end,
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        vim.ui.select = function(...)
          require("lazy").load({ plugins = { "fzf-lua" } })

          local Plugin = require("lazy.core.plugin")
          local opts = Plugin.values("fzf-lua", "opts", false) or {}

          require("fzf-lua").register_ui_select(function(_, items)
            local min_h, max_h = 0.15, 0.70
            local h = (#items + 4) / vim.o.lines
            if h < min_h then
              h = min_h
            elseif h > max_h then
              h = max_h
            end
            return { winopts = { height = h, width = 0.60, row = 0.40 } }
          end)

          return vim.ui.select(...)
        end

        local map = vim.g.remap
        local utils = require("devastion.utils")
        local is_file_readable = utils.is_file_readable

        if is_file_readable("composer.json") then
          map("<leader>fc", function()
            require("fzf-lua").files({
              cmd = "fd -g -p -t f '**/controllers/**'",
            })
          end, "Controllers", "n")
          map("<leader>fm", function()
            require("fzf-lua").files({
              cmd = "fd -g -p -t f '**/models/**' --exclude='tests'",
            })
          end, "Models", "n")
          map("<leader>fs", function()
            require("fzf-lua").files({
              cmd = "fd -g -p -t f '**/services/**' --exclude='tests'",
            })
          end, "Services", "n")
          map("<leader>ft", function()
            require("fzf-lua").files({
              cmd = "fd -g -p -t f '**/tests/**'",
            })
          end, "Tests", "n")
        end

        if is_file_readable("lazy-lock.json", true) then
          map("<leader>fp", function()
            require("fzf-lua").files({
              cmd = "fd -g -p -t f '**/plugins/*'",
            })
          end, "Plugins", "n")
          map("<leader>fl", function()
            require("fzf-lua").files({
              cmd = "fd -g -p -t f '**/lsp/*'",
            })
          end, "LSP", "n")
          map("<leader>ft", function()
            require("fzf-lua").files({
              cmd = "fd -g -p -t f '**/ftplugin/**'",
            })
          end, "FTPlugin", "n")
          map("<leader>fc", function()
            require("fzf-lua").files({
              cmd = "fd -g -p -t f '**/core/**'",
            })
          end, "Core", "n")
          map("<leader>fh", function()
            require("fzf-lua").files({
              cmd = "fd -g -p -t f '**/helpers/*'",
            })
          end, "Helpers", "n")
        end
      end,
    })
  end,
  keys = {
    -- Find
    {
      "<leader>:",
      function()
        require("fzf-lua").command_history()
      end,
      mode = "n",
      desc = "Command History",
    },
    {
      "<leader>ff",
      function()
        require("fzf-lua").files()
      end,
      mode = "n",
      desc = "Files (root)",
    },
    {
      "<leader>fF",
      function()
        require("fzf-lua").files({ cwd = vim.fn.expand("%:p:h") })
      end,
      mode = "n",
      desc = "Files (cwd)",
    },
    {
      "<leader>fb",
      function()
        require("fzf-lua").buffers({ sort_mru = true, sort_lastused = true })
      end,
      mode = "n",
      desc = "Buffers (root)",
    },
    {
      "<leader>fB",
      function()
        require("fzf-lua").buffers({ cwd = vim.fn.expand("%:p:h"), sort_mru = true, sort_lastused = true })
      end,
      mode = "n",
      desc = "Buffers (cwd)",
    },
    {
      "<leader>fg",
      function()
        require("fzf-lua").git_files()
      end,
      mode = "n",
      desc = "Git Files",
    },
    {
      "<leader>fr",
      function()
        require("fzf-lua").oldfiles()
      end,
      mode = "n",
      desc = "Recent Files",
    },
    {
      "<leader>fT",
      function()
        require("fzf-lua").filetypes()
      end,
      mode = "n",
      desc = "Filetypes",
    },
    {
      "<leader>f<tab>",
      function()
        require("fzf-lua").tabs()
      end,
      mode = "n",
      desc = "Tabs",
    },

    -- Search
    {
      "<leader>s'",
      function()
        require("fzf-lua").marks()
      end,
      mode = "n",
      desc = "Marks",
    },
    {
      '<leader>s"',
      function()
        require("fzf-lua").registers()
      end,
      mode = "n",
      desc = "Registers",
    },
    {
      "<leader>sa",
      function()
        require("fzf-lua").autocmds()
      end,
      mode = "n",
      desc = "Autocommands",
    },
    {
      "<leader>sb",
      function()
        require("fzf-lua").lgrep_curbuf()
      end,
      mode = "n",
      desc = "Grep (current buffer)",
    },
    {
      "<leader>sB",
      function()
        require("fzf-lua").builtin()
      end,
      mode = "n",
      desc = "Fzf-Lua Builtin Commands",
    },
    {
      "<leader>sc",
      function()
        require("fzf-lua").commands()
      end,
      mode = "n",
      desc = "Commands",
    },
    {
      "<leader>sC",
      function()
        require("fzf-lua").command_history()
      end,
      mode = "n",
      desc = "Command History",
    },
    {
      "<leader>sd",
      function()
        require("fzf-lua").diagnostics_workspace({ severity_limit = vim.diagnostic.severity.WARN })
      end,
      mode = "n",
      desc = "Diagnostics (workspace)",
    },
    {
      "<leader>sD",
      function()
        require("fzf-lua").diagnostics_document({ severity_limit = vim.diagnostic.severity.WARN })
      end,
      mode = "n",
      desc = "Diagnostics (document)",
    },
    {
      "<leader>sg",
      function()
        require("fzf-lua").live_grep()
      end,
      mode = "n",
      desc = "Grep (live)",
    },
    {
      "<leader>sG",
      function()
        require("devastion.helpers.fzf").folder_grep()
      end,
      mode = "n",
      desc = "Grep in Folder",
    },
    {
      "<leader>sg",
      function()
        require("fzf-lua").grep_visual()
      end,
      mode = "v",
      desc = "Grep (visual)",
    },
    {
      "<leader>sh",
      function()
        require("fzf-lua").help_tags()
      end,
      mode = "n",
      desc = "Help Tags",
    },
    {
      "<leader>sH",
      function()
        require("fzf-lua").highlights()
      end,
      mode = "n",
      desc = "Highlights",
    },
    {
      "<leader>sj",
      function()
        require("fzf-lua").jumps()
      end,
      mode = "n",
      desc = "Jumps",
    },
    {
      "<leader>sk",
      function()
        require("fzf-lua").keymaps()
      end,
      mode = "n",
      desc = "Keymaps",
    },
    {
      "<leader>sl",
      function()
        require("fzf-lua").loclist()
      end,
      mode = "n",
      desc = "Location List",
    },
    {
      "<leader>sm",
      function()
        require("fzf-lua").marks()
      end,
      mode = "n",
      desc = "Marks",
    },
    {
      "<leader>sM",
      function()
        require("fzf-lua").man_pages()
      end,
      mode = "n",
      desc = "Man Pages",
    },
    {
      "<leader>sq",
      function()
        require("fzf-lua").quickfix()
      end,
      mode = "n",
      desc = "Quickfix List",
    },
    {
      "<leader>sr",
      function()
        require("fzf-lua").resume()
      end,
      mode = "n",
      desc = "Resume",
    },
    {
      "<leader>sR",
      function()
        require("fzf-lua").grep_last()
      end,
      mode = "n",
      desc = "Grep Last",
    },
    {
      "<leader>sw",
      function()
        require("fzf-lua").grep_cword()
      end,
      mode = "n",
      desc = "Grep (word under cursor)",
    },
    {
      "<leader>sW",
      function()
        require("fzf-lua").grep_cWORD()
      end,
      mode = "n",
      desc = "Grep (WORD under cursor)",
    },

    -- Git
    {
      "<leader>gb",
      function()
        require("fzf-lua").git_blame()
      end,
      mode = "n",
      desc = "Blame (buffer)",
    },
    {
      "<leader>gB",
      function()
        require("fzf-lua").git_branches()
      end,
      mode = "n",
      desc = "Branches",
    },
    {
      "<leader>gs",
      function()
        require("fzf-lua").git_status()
      end,
      mode = "n",
      desc = "Status",
    },
    {
      "<leader>gS",
      function()
        require("fzf-lua").git_stash()
      end,
      mode = "n",
      desc = "Stash",
    },
    {
      "<leader>gl",
      function()
        require("fzf-lua").git_commits()
      end,
      mode = "n",
      desc = "Log",
    },
    {
      "<leader>gL",
      function()
        require("fzf-lua").git_bcommits()
      end,
      mode = "n",
      desc = "Log (file)",
    },
    {
      "<leader>gT",
      function()
        require("fzf-lua").git_tags()
      end,
      mode = "n",
      desc = "Tags",
    },
    {
      "<leader>gd",
      function()
        require("fzf-lua").git_diff()
      end,
      mode = "n",
      desc = "Diffs",
    },
    {
      "<leader>fx",
      function()
        require("devastion.helpers.fzf").git_conflicts()
      end,
      desc = "Conflicts",
    },

    -- DAP
    {
      "<leader>ds",
      "",
      desc = "+[FZF]",
    },
    {
      "<leader>dsc",
      function()
        require("fzf-lua").dap_commands()
      end,
      desc = "Commands",
    },
    {
      "<leader>dsC",
      function()
        require("fzf-lua").dap_configurations()
      end,
      desc = "Configuratiosn",
    },
    {
      "<leader>dsb",
      function()
        require("fzf-lua").dap_breakpoints()
      end,
      desc = "Breakpoints",
    },
    {
      "<leader>dsv",
      function()
        require("fzf-lua").dap_variables()
      end,
      desc = "Variables",
    },
    {
      "<leader>dsf",
      function()
        require("fzf-lua").dap_frames()
      end,
      desc = "Frames",
    },
  },
}
