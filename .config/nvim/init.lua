_G.Devastion = {}

function Devastion.is_loaded(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param name string
---@param fn fun(name:string)
function Devastion.on_load(name, fn)
  if Devastion.is_loaded(name) then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

---@param name string
function Devastion.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

---@param name string
---@param path string?
function Devastion.get_plugin_path(name, path)
  local plugin = Devastion.get_plugin(name)
  path = path and "/" .. path or ""
  return plugin and (plugin.dir .. path)
end

---@param plugin string
function Devastion.has(plugin)
  return Devastion.get_plugin(plugin) ~= nil
end

Devastion.mini = require("devastion.helpers.mini")
Devastion.lsp = require("devastion.helpers.lsp")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("devastion.core.globals")
require("devastion.core.options")
require("devastion.core.filetypes")
require("devastion.core.autocmds")
require("devastion.core.usercmds")
require("devastion.core.keymaps")
require("devastion.core.diagnostics")

require("lazy").setup({
  spec = {
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = { style = "night" },
      config = function(_, opts)
        require("tokyonight").setup(opts)
        vim.api.nvim_cmd({
          cmd = "colorscheme",
          args = { "tokyonight-night" },
        }, {})
      end,
    },
    { "nvim-lua/plenary.nvim", lazy = true },
    { "muniftanjim/nui.nvim", lazy = true },
    { import = "devastion.plugins" },
  },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = false },
  change_detection = { notify = false },
  ui = {
    border = "single",
    size = {
      width = 0.8,
      height = 0.8,
    },
  },
  dev = {
    path = "~/projects/github/neovim-plugins",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
