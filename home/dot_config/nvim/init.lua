vim.loader.enable()

--- `require()` that surfaces the error instead of aborting your config.
---@param mod string
---@return boolean ok, any module_or_err
local function try_require(mod)
  local ok, res = pcall(require, mod)
  if not ok then
    vim.notify(
      ('Failed to load %s:\n%s'):format(mod, res),
      vim.log.levels.ERROR,
      { title = mod }
    )
  end
  return ok, res
end

try_require('config.globals')
try_require('config.options')
try_require('config.filetypes')
try_require('config.keymaps')
try_require('config.autocmds')
try_require('config.diagnostics')
try_require('config.commands')

try_require('plugins.tokyonight')
try_require('plugins.mini_icons')
try_require('plugins.notify')

try_require('plugins.treesitter')

try_require('plugins.which-key')
try_require('plugins.blink')

local fzf_ok, fzf = try_require('plugins.fzf')
if fzf_ok then fzf.setup() end

try_require('plugins.mini_files')
try_require('plugins.mini_sessions')
try_require('plugins.mini_operators')
try_require('plugins.mini_align')
try_require('plugins.mini_indentscope')
try_require('plugins.mini_comment')
try_require('plugins.chezmoi')
try_require('plugins.treesj')
try_require('plugins.surround')
try_require('plugins.vim-wordmotion')
try_require('plugins.gitsigns')
try_require('plugins.conform')
try_require('plugins.lint')
try_require('plugins.render-markdown')
try_require('plugins.highlight-colors')
try_require('plugins.dial')
try_require('plugins.sidekick')
try_require('plugins.refactoring')
try_require('plugins.codedocs')
try_require('plugins.live-rename')
try_require('plugins.schemastore')
try_require('plugins.workspace-diagnostics')
try_require('plugins.symbol-usage')
try_require('plugins.lualine')
try_require('plugins.flash')
try_require('plugins.grug-far')
try_require('plugins.csvview')
try_require('plugins.noice')

local mason_ok, mason = try_require('plugins.mason')
if mason_ok then
  mason.install({ 'fzf', 'ripgrep', 'ast-grep' })
  mason.install(vim.tbl_values(vim.g.LSP_SERVERS))
end

vim.lsp.enable(vim.tbl_keys(vim.g.LSP_SERVERS))
