vim.pack.add({
  'https://github.com/nvim-mini/mini.icons',
}, { confirm = false })

local icons = require('config.icons')
local mini_icons = require('mini.icons')

local ext3_blocklist = { scm = true, txt = true, yml = true }
local ext4_blocklist = { json = true, yaml = true }

mini_icons.setup({
  use_file_extension = function(ext, _)
    return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
  end,
  filetype = icons.convert_to_mini('filetype'),
  lsp = icons.convert_to_mini('kinds'),
})

mini_icons.mock_nvim_web_devicons()
