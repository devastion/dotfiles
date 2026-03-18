local safe_require = require("devastion.utils").safe_require

---------------------------------------------------------------------------
-- Core configuration (order matters — globals first, then options)
---------------------------------------------------------------------------
safe_require("devastion.config.globals")
safe_require("devastion.config.options")
safe_require("devastion.config.filetypes")

---------------------------------------------------------------------------
-- Base dependencies (library plugins used by others)
---------------------------------------------------------------------------
local pkg_ok, pkg = pcall(require, "devastion.utils.pkg")
if pkg_ok then
  pkg.add({
    "nvim-lua/plenary.nvim",
    "muniftanjim/nui.nvim",
    "kkharji/sqlite.lua",
  })
end

---------------------------------------------------------------------------
-- Early-loaded packages (must be available before autocmds / UI renders)
---------------------------------------------------------------------------
local early_packages = {
  "devastion.packages.mini.icons",
  "devastion.packages.treesitter",
  "devastion.packages.tokyonight",
  "devastion.packages.mini.misc",
  "devastion.packages.auto-session",
}

for _, mod in ipairs(early_packages) do
  safe_require(mod)
end

---------------------------------------------------------------------------
-- Autocmds (depends on early packages being available)
---------------------------------------------------------------------------
safe_require("devastion.config.autocmds")

---------------------------------------------------------------------------
-- Packages
---------------------------------------------------------------------------
local packages = {
  -- Code outline & sidebar (sidekick before lualine — lualine depends on sidekick.status)
  "devastion.packages.sidekick",
  "devastion.packages.resolve",

  -- UI
  "devastion.packages.noice",
  "devastion.packages.lualine",
  "devastion.packages.which-key",
  "devastion.packages.highlight-colors",
  "devastion.packages.stay-centered",
  "devastion.packages.render-markdown",
  "devastion.packages.markdown-preview",

  -- Navigation & Search
  "devastion.packages.fzf",
  "devastion.packages.flash",
  "devastion.packages.arrow",
  "devastion.packages.marks",
  "devastion.packages.smart-splits",
  "devastion.packages.grug-far",

  -- Git
  "devastion.packages.gitsigns",
  "devastion.packages.neogit",
  "devastion.packages.commitpad",

  -- LSP, Completion, Linting & Formatting
  "devastion.packages.mason",
  "devastion.packages.lsp",
  "devastion.packages.blink",
  "devastion.packages.conform",
  "devastion.packages.lint",

  -- Editing & Refactoring
  "devastion.packages.dial",
  "devastion.packages.genghis",
  "devastion.packages.guess-indent",
  "devastion.packages.refactoring",
  "devastion.packages.neogen",
  "devastion.packages.scissors",
  "devastion.packages.yanky",
  "devastion.packages.spider",

  -- Testing & Debugging
  "devastion.packages.dap",
  "devastion.packages.neotest",

  -- Misc
  "devastion.packages.csvview",
  "devastion.packages.package-info",
  "devastion.packages.otter",
  "devastion.packages.snacks",
  "devastion.packages.todo-comments",
  "devastion.packages.text-case",
}

for _, mod in ipairs(packages) do
  safe_require(mod)
end

---------------------------------------------------------------------------
-- Mini.nvim modules
---------------------------------------------------------------------------
local mini_modules = {
  "files",
  "pairs",
  "surround",
  "indentscope",
  "operators",
  "splitjoin",
  "align",
  "move",
  "comment",
  "git",
}

for _, mod in ipairs(mini_modules) do
  safe_require("devastion.packages.mini." .. mod)
end

---------------------------------------------------------------------------
-- Keymaps, user commands & diagnostics (loaded last)
---------------------------------------------------------------------------
safe_require("devastion.config.usercmds")
safe_require("devastion.config.keymaps")
safe_require("devastion.config.diagnostics")

---------------------------------------------------------------------------
-- Extras
---------------------------------------------------------------------------
local extras = {
  -- "devastion.extras.laravel",
}

for _, mod in ipairs(extras) do
  safe_require(mod)
end
