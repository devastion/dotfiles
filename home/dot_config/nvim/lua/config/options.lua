local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = 'yes'
opt.colorcolumn = '+1'
opt.wrap = false
opt.linebreak = true
opt.showbreak = '↳ '
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.termguicolors = true
opt.showmode = false
opt.showtabline = 0
opt.laststatus = 3
opt.cmdheight = 0
opt.pumheight = 10
opt.winborder = 'rounded'
opt.list = true
opt.listchars = {
  extends = '…',
  nbsp = '␣',
  precedes = '…',
  tab = '» ',
  trail = '·',
}
opt.fillchars = {
  diff = ' ',
  eob = ' ',
  fold = ' ',
  foldclose = ' ',
  foldopen = ' ',
}

-- Indentation
opt.expandtab = true
opt.shiftwidth = 0
opt.tabstop = 2
opt.softtabstop = -1
opt.smartindent = true
opt.breakindent = true
opt.breakindentopt = 'list:-1'

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = 'split'

-- Splits
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = 'screen'
opt.tabclose = 'uselast'

-- Files / undo / sessions
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undolevels = 100000
opt.autoread = true
opt.confirm = true
opt.shadafile = vim.fs.joinpath(vim.fn.stdpath('state'), 'main.shada')
opt.exrc = true
opt.sessionoptions = {
  'buffers',
  'curdir',
  'tabpages',
  'winsize',
  'help',
  'folds',
}

-- Timing
opt.updatetime = 200
opt.timeoutlen = 400
opt.ttimeoutlen = 10

-- Completion
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.wildmode = 'longest:full,full'

-- Folding
opt.foldmethod = 'indent'
opt.foldlevel = 10
opt.foldnestmax = 10
opt.foldtext = ''

-- Spelling
opt.spelllang = 'en'
opt.spelloptions = { 'camel', 'noplainbuffer' }
opt.spellfile =
  vim.fs.joinpath(vim.fn.stdpath('config'), 'spell', 'en.utf-8.add')
opt.spellcapcheck = ''
opt.spellsuggest = { 'best', '9' }

-- Messages
opt.shortmess = {
  A = true, -- no ATTENTION (swapfile)
  C = true, -- no completion scanning messages
  F = true, -- no file info on edit
  I = true, -- no intro
  O = true, -- read / quickfix overwrites previous
  S = true, -- no search count
  T = true, -- truncate other long messages
  W = true, -- no "written"
  a = true, -- abbreviate f/i/l/m/n/r/w/x
  c = true, -- no completion menu messages
  o = true, -- overwrite write message with subsequent read
  q = true, -- no "recording @a"
  s = true, -- no search wrap messages
  t = true, -- truncate long file messages
}

-- Format Options
opt.formatoptions = {
  B = false, -- don't skip space between multibyte chars when joining
  M = false, -- don't skip spaces around multibyte when joining
  ['/'] = false, -- with 'o': don't continue // comments mid-statement
  ['1'] = true, -- don't prefer break before one-letter words
  ['2'] = false, -- don't use 2nd-line indent for paragraphs
  [']'] = false, -- don't rigorously enforce 'textwidth' (CJK)
  a = false, -- no automatic paragraph reformatting
  b = false, -- no 'v'-like wrap only at blanks before margin
  c = false, -- don't auto-wrap comments using 'textwidth'
  j = true, -- remove comment leader when joining lines
  l = true, -- don't break already-long lines in Insert
  m = false, -- don't break at multibyte chars > 255
  n = true, -- recognize numbered lists ('formatlistpat')
  o = false, -- don't insert comment leader after o/O
  p = false, -- don't avoid breaks after single space following period
  q = true, -- allow formatting comments with gq
  r = false, -- don't insert comment leader after <Enter> in Insert
  t = true, -- auto-wrap text using 'textwidth'
  v = false, -- no Vi-compatible insert auto-wrap
  w = false, -- trailing whitespace continues a paragraph
}

-- Misc
opt.clipboard = 'unnamedplus'
opt.mouse = 'a'
opt.virtualedit = 'block'
opt.diffopt:append('linematch:60')
opt.grepprg = 'rg --vimgrep --smart-case'
opt.grepformat = '%f:%l:%c:%m'
opt.matchpairs:append('<:>')
opt.iskeyword:append('-')

if vim.env.SUDO_USER ~= nil then
  opt.swapfile = false
  opt.backup = false
  opt.writebackup = false
  opt.undofile = false
  opt.shadafile = 'NONE'
  opt.exrc = false
  opt.modeline = false
end
