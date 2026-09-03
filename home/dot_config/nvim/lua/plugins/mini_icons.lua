vim.pack.add({
  'https://github.com/nvim-mini/mini.icons',
}, { confirm = false })

local icons = require('config.icons')

local ext3_blocklist = { scm = true, txt = true, yml = true }
local ext4_blocklist = { json = true, yaml = true }

local filetype = {}
for ft, glyph in pairs(icons.filetype) do
  filetype[ft:lower()] = { glyph = glyph }
end

local lsp = {}
for kind, glyph in pairs(icons.kinds) do
  lsp[kind:lower()] = { glyph = glyph }
end

require('mini.icons').setup({
  use_file_extension = function(ext, _)
    return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
  end,
  filetype = filetype,
  lsp = lsp,
})
