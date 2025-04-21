local g = vim.g

g.mapleader = vim.keycode("<Space>")
g.maplocalleader = vim.keycode("<Bslash>")

-- Disable some default providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
