---@type vim.lsp.Config
return {
  cmd = { 'shuck', 'server' },
  filetypes = { 'zsh' },
  root_markers = { '.shuck.toml', 'shuck.toml', '.git' },
}
