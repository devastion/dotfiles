vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" }, { confirm = false })

local fzf = require("fzf-lua")
local actions = fzf.actions
fzf.setup({
  "hide",
  keymap = {
    builtin = { ["<C-f>"] = "preview-page-down", ["<C-b>"] = "preview-page-up" },
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
  winopts = { width = 0.8, height = 0.8, row = 0.5, col = 0.5, preview = { scrollchars = { "┃", "" } } },
  files = {
    cwd_prompt = false,
    actions = { ["alt-i"] = { actions.toggle_ignore }, ["alt-h"] = { actions.toggle_hidden } },
  },
  grep = { actions = { ["alt-i"] = { actions.toggle_ignore }, ["alt-h"] = { actions.toggle_hidden } } },
  lsp = { code_actions = { previewer = "codeaction_native" } },
  oldfiles = { cwd_only = true, include_current_session = true, winopts = { preview = { hidden = true } } },
})
fzf.register_ui_select()

-- Find
vim.keymap.set("n", "<leader>:", function() require("fzf-lua").command_history() end, { desc = "Command History" })
vim.keymap.set("n", "<leader>ff", function() require("fzf-lua").files() end, { desc = "Files (root)" })
vim.keymap.set(
  "n",
  "<leader>fF",
  function() require("fzf-lua").files({ cwd = vim.fn.expand("%:p:h") }) end,
  { desc = "Files (cwd)" }
)
vim.keymap.set(
  "n",
  "<leader>fb",
  function() require("fzf-lua").buffers({ sort_mru = true, sort_lastused = true }) end,
  { desc = "Buffers (root)" }
)
vim.keymap.set(
  "n",
  "<leader>fB",
  function() require("fzf-lua").buffers({ cwd = vim.fn.expand("%:p:h"), sort_mru = true, sort_lastused = true }) end,
  { desc = "Buffers (cwd)" }
)
vim.keymap.set("n", "<leader>fg", function() require("fzf-lua").git_files() end, { desc = "Git Files" })
vim.keymap.set("n", "<leader>fr", function() require("fzf-lua").oldfiles() end, { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fT", function() require("fzf-lua").filetypes() end, { desc = "Filetypes" })
vim.keymap.set("n", "<leader>f<tab>", function() require("fzf-lua").tabs() end, { desc = "Tabs" })

-- Search
vim.keymap.set("n", "<leader>s'", function() require("fzf-lua").marks() end, { desc = "Marks" })
vim.keymap.set("n", '<leader>s"', function() require("fzf-lua").registers() end, { desc = "Registers" })
vim.keymap.set("n", "<leader>sa", function() require("fzf-lua").autocmds() end, { desc = "Autocommands" })
vim.keymap.set("n", "<leader>sb", function() require("fzf-lua").lgrep_curbuf() end, { desc = "Grep (current buffer)" })
vim.keymap.set("n", "<leader>sB", function() require("fzf-lua").builtin() end, { desc = "Fzf-Lua Builtin Commands" })
vim.keymap.set("n", "<leader>sc", function() require("fzf-lua").commands() end, { desc = "Commands" })
vim.keymap.set("n", "<leader>sC", function() require("fzf-lua").command_history() end, { desc = "Command History" })
vim.keymap.set(
  "n",
  "<leader>sd",
  function() require("fzf-lua").diagnostics_workspace() end,
  { desc = "Diagnostics (workspace)" }
)
vim.keymap.set(
  "n",
  "<leader>sD",
  function() require("fzf-lua").diagnostics_document() end,
  { desc = "Diagnostics (document)" }
)
vim.keymap.set("n", "<leader>sg", function() require("fzf-lua").live_grep_native() end, { desc = "Grep (live)" })
vim.keymap.set("v", "<leader>sg", function() require("fzf-lua").grep_visual() end, { desc = "Grep (visual)" })
vim.keymap.set("n", "<leader>sh", function() require("fzf-lua").help_tags() end, { desc = "Help Tags" })
vim.keymap.set("n", "<leader>sH", function() require("fzf-lua").highlights() end, { desc = "Highlights" })
vim.keymap.set("n", "<leader>sj", function() require("fzf-lua").jumps() end, { desc = "Jumps" })
vim.keymap.set("n", "<leader>sk", function() require("fzf-lua").keymaps() end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>sl", function() require("fzf-lua").loclist() end, { desc = "Location List" })
vim.keymap.set("n", "<leader>sm", function() require("fzf-lua").marks() end, { desc = "Marks" })
vim.keymap.set("n", "<leader>sM", function() require("fzf-lua").man_pages() end, { desc = "Man Pages" })
vim.keymap.set("n", "<leader>sq", function() require("fzf-lua").quickfix() end, { desc = "Quickfix List" })
vim.keymap.set("n", "<leader>sr", function() require("fzf-lua").resume() end, { desc = "Resume" })
vim.keymap.set("n", "<leader>sw", function() require("fzf-lua").grep_cword() end, { desc = "Grep (word under cursor)" })
vim.keymap.set("n", "<leader>sW", function() require("fzf-lua").grep_cWORD() end, { desc = "Grep (WORD under cursor)" })

-- Git
vim.keymap.set("n", "<leader>gb", function() require("fzf-lua").git_blame() end, { desc = "Blame (buffer)" })
vim.keymap.set("n", "<leader>gB", function() require("fzf-lua").git_branches() end, { desc = "Branches" })
vim.keymap.set("n", "<leader>gs", function() require("fzf-lua").git_status() end, { desc = "Status" })
vim.keymap.set("n", "<leader>gS", function() require("fzf-lua").git_stash() end, { desc = "Stash" })
vim.keymap.set("n", "<leader>gl", function() require("fzf-lua").git_commits() end, { desc = "Log" })
vim.keymap.set("n", "<leader>gL", function() require("fzf-lua").git_bcommits() end, { desc = "Log (file)" })
vim.keymap.set("n", "<leader>gT", function() require("fzf-lua").git_tags() end, { desc = "Tags" })
vim.keymap.set("n", "<leader>gd", function() require("fzf-lua").git_diff() end, { desc = "Diffs" })
