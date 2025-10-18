vim.g.mapleader = vim.keycode("<Space>")
vim.g.maplocalleader = vim.keycode("<Bslash>")

local utils = require("devastion.utils")

vim.g.is_laravel_project = utils.package_exists("composer.json", '.require."laravel/framework"')
