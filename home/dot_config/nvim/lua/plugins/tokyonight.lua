vim.pack.add({
  'https://github.com/folke/tokyonight.nvim',
}, { confirm = false })

require('tokyonight').setup({
  style = 'night',
  transparent = true,
  styles = {
    sidebars = 'transparent',
    floats = 'transparent',
  },
  on_highlights = function(hl, c)
    hl['WinSeparator'] = { fg = c.fg_gutter }
  end,
})

vim.cmd.colorscheme('tokyonight')
