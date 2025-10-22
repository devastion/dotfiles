vim.g.mapleader = vim.keycode("<space>")
vim.g.maplocalleader = vim.keycode("<bslash>")

vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.g.autolint_enabled = true
vim.g.autoformat_enabled = false

vim.g.ui_border = "single"

local utils = require("devastion.utils")

vim.g.remap = utils.remap
vim.g.custom_foldtext = utils.custom_foldtext

vim.g.is_laravel_project = utils.package_exists("composer.json", '.require."laravel/framework"')
