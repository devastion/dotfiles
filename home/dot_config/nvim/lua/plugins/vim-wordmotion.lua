vim.g.wordmotion_mappings = {
  ['w'] = 'w',
  ['b'] = 'b',
  ['e'] = 'e',
  ['ge'] = 'ge',
  ['aw'] = 'av',
  ['iw'] = 'iv',
  ['<C-R><C-W>'] = '<C-R><C-W>',
}

vim.pack.add(
  { 'https://github.com/chaoren/vim-wordmotion' },
  { confirm = false }
)
