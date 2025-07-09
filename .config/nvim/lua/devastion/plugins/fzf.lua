---@type LazySpec
return {
  "ibhagwan/fzf-lua",
  dependencies = {
    {
      "otavioschwanck/fzf-lua-enchanted-files",
      config = function()
        vim.g.fzf_lua_enchanted_files = {
          max_history_per_cwd = 50,
        }
      end,
    },
  },
  opts = function()
    local fzf = require("fzf-lua")
    local config = fzf.config
    local actions = fzf.actions

    -- Quickfix
    config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
    config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
    config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
    config.defaults.keymap.fzf["ctrl-x"] = "jump"
    config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
    config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
    config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
    config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

    return {
      "hide",
      fzf_colors = true,
      fzf_opts = {
        ["--no-scrollbar"] = true,
      },
      defaults = {
        -- formatter = "path.filename_first",
        formatter = "path.dirname_first",
      },
      winopts = {
        width = 0.8,
        height = 0.8,
        row = 0.5,
        col = 0.5,
        preview = {
          scrollchars = { "┃", "" },
        },
      },
      files = {
        cwd_prompt = false,
        actions = {
          ["alt-i"] = { actions.toggle_ignore },
          ["alt-h"] = { actions.toggle_hidden },
        },
      },
      grep = {
        actions = {
          ["alt-i"] = { actions.toggle_ignore },
          ["alt-h"] = { actions.toggle_hidden },
        },
      },
      lsp = {
        code_actions = {
          previewer = "codeaction_native",
        },
      },
      oldfiles = {
        cwd_only = true,
        include_current_session = true,
        winopts = {
          preview = { hidden = true },
        },
      },
    }
  end,
  init = function() require("fzf-lua").register_ui_select({}) end,
  keys = {
    -- Find
    { "<leader>:", function() require("fzf-lua").command_history({}) end, desc = "Command History" },
    -- INFO: Replaced below with fzf-lua-enchanted-files. Currently is a bit
    -- slow, but hopefully will be fixed in the future

    -- { "<leader>ff", function() require("fzf-lua").files({}) end, desc = "Files (root) " },
    -- {
    --   "<leader>fF",
    --   function() require("fzf-lua").files({ cwd = require("devastion.utils.path").buffer_dir() }) end,
    --   desc = "Files (cwd)",
    -- },
    { "<leader>ff", function() require("fzf-lua-enchanted-files").files({}) end, desc = "Files (root) " },
    {
      "<leader>fF",
      function() require("fzf-lua-enchanted-files").files({ cwd = require("devastion.utils.path").buffer_dir() }) end,
      desc = "Files (cwd)",
    },
    {
      "<leader>fb",
      function() require("fzf-lua").buffers({ sort_mru = true, sort_lastused = true }) end,
      desc = "Buffers (root) ",
    },
    {
      "<leader>fB",
      function()
        require("fzf-lua").buffers({
          cwd = require("devastion.utils.path").buffer_dir(),
          sort_mru = true,
          sort_lastused = true,
        })
      end,
      desc = "Buffers (root) ",
    },
    { "<leader>fr", function() require("fzf-lua").oldfiles({}) end, desc = "Recent Files" },
    { "<leader>fg", function() require("fzf-lua").git_files({}) end, desc = "Git Files" },
    { "<leader>fT", function() require("fzf-lua").filetypes({}) end, desc = "Filetypes" },
    { "<leader>f<tab>", function() require("fzf-lua").tabs({}) end, desc = "Tabs" },
    -- Search
    { "<leader>s'", function() require("fzf-lua").marks({}) end, desc = "Marks" },
    { '<leader>s"', function() require("fzf-lua").registers({}) end, desc = "Registers" },
    { "<leader>sa", function() require("fzf-lua").autocmds({}) end, desc = "Autocommands" },
    { "<leader>sb", function() require("fzf-lua").lgrep_curbuf({}) end, desc = "Grep (current buffer)" },
    { "<leader>sB", function() require("fzf-lua").builtin({}) end, desc = "Fzf-Lua Builtin Commands" },
    { "<leader>sc", function() require("fzf-lua").commands({}) end, desc = "Commands" },
    { "<leader>sC", function() require("fzf-lua").command_history({}) end, desc = "Command History" },
    { "<leader>sd", function() require("fzf-lua").diagnostics_workspace({}) end, desc = "Diagnostics (workspace)" },
    { "<leader>sD", function() require("fzf-lua").diagnostics_document({}) end, desc = "Diagnostics (document)" },
    { "<leader>sg", function() require("fzf-lua").live_grep_native({}) end, desc = "Grep (live)" },
    { "<leader>sg", function() require("fzf-lua").grep_visual({}) end, desc = "Grep (visual)", mode = "v" },
    { "<leader>sh", function() require("fzf-lua").help_tags({}) end, desc = "Help Tags" },
    { "<leader>sH", function() require("fzf-lua").highlights({}) end, desc = "Highlights" },
    { "<leader>sj", function() require("fzf-lua").jumps({}) end, desc = "Jumps" },
    { "<leader>sk", function() require("fzf-lua").keymaps({}) end, desc = "Keymaps" },
    { "<leader>sl", function() require("fzf-lua").loclist({}) end, desc = "Location List" },
    { "<leader>sm", function() require("fzf-lua").marks({}) end, desc = "Marks" },
    { "<leader>sM", function() require("fzf-lua").man_pages({}) end, desc = "Man Pages" },
    { "<leader>sq", function() require("fzf-lua").quickfix({}) end, desc = "Quickfix List" },
    { "<leader>sr", function() require("fzf-lua").resume({}) end, desc = "Resume" },
    { "<leader>sw", function() require("fzf-lua").grep_cword({}) end, desc = "Grep (word under cursor)" },
    { "<leader>sW", function() require("fzf-lua").grep_cWORD({}) end, desc = "Grep (WORD under cursor)" },
    -- Git
    { "<leader>gb", function() require("fzf-lua").git_blame({}) end, desc = "Blame (buffer)" },
    { "<leader>gB", function() require("fzf-lua").git_branches({}) end, desc = "Branches" },
    { "<leader>gs", function() require("fzf-lua").git_status({}) end, desc = "Status" },
    { "<leader>gS", function() require("fzf-lua").git_stash({}) end, desc = "Stash" },
    { "<leader>gl", function() require("fzf-lua").git_commits({}) end, desc = "Log" },
    { "<leader>gL", function() require("fzf-lua").git_bcommits({}) end, desc = "Log (file)" },
    -- Insert Mode Completions
    {
      "<C-x><C-f>",
      function() require("fzf-lua").complete_file({ cmd = "rg --files", winopts = { preview = { hidden = true } } }) end,
      desc = "Fuzzy Complete File",
      mode = "i",
      silent = true,
    },
  },
}
