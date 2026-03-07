vim.g.mapleader = vim.keycode("<space>")
vim.g.maplocalleader = vim.keycode("<bslash>")

-- Disable built-in ftplugin mappings
vim.g.no_plugin_maps = true

vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- UI
vim.g.diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = "✘",
  [vim.diagnostic.severity.WARN] = "▲",
  [vim.diagnostic.severity.HINT] = "⚑",
  [vim.diagnostic.severity.INFO] = "»",
}
vim.g.border_style = "single"

local luarocks_path = {
  lua = vim.fn.trim(vim.fn.system("luarocks --lua-version 5.1 path --lr-path")),
  c = vim.fn.trim(vim.fn.system("luarocks --lua-version 5.1 path --lr-cpath")),
}

if luarocks_path.lua ~= "" then
  package.path = package.path .. ";" .. luarocks_path.lua
end

if luarocks_path.c ~= "" then
  package.cpath = package.cpath .. ";" .. luarocks_path.c
end
