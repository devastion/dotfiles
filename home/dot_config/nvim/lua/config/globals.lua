vim.g.mapleader = [[ ]]
vim.g.maplocalleader = [[\]]

vim.g.no_plugin_maps = true

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

vim.g.netrw_winsize = 20
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 1

if vim.env.SSH_TTY then
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
      ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
  }
end

vim.g.LSP_SERVERS = {
  bash_ls = 'bash-language-server',
  clangd = 'clangd',
  css_ls = 'css-lsp',
  docker_ls = 'docker-language-server',
  gopls = 'gopls',
  html_ls = 'html-lsp',
  intelephense = 'intelephense',
  json_ls = 'json-lsp',
  lua_ls = 'lua-language-server',
  markdown_oxide = 'markdown-oxide',
  marksman = 'marksman',
  pyright = 'pyright',
  taplo = 'taplo',
  vts_ls = 'vtsls',
  yaml_ls = 'yaml-language-server',
}
