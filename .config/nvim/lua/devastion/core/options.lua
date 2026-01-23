local opt = vim.opt

-- General
opt.mouse = ""
opt.updatetime = 200
opt.timeoutlen = 300
opt.autowrite = true
opt.autowriteall = true
opt.autoread = true
opt.confirm = true
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.completeopt = { "menu", "menuone", "noselect", "fuzzy" }
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.sidescrolloff = 8
opt.virtualedit = "block"
opt.ruler = false
opt.switchbuf = "usetab"

-- Per-directory config
opt.exrc = true
opt.secure = true

-- Sign Column & Line Numbers
opt.signcolumn = "yes"
opt.number = true
opt.relativenumber = true

-- UI
opt.background = "dark"
opt.showmode = false
opt.showcmd = false
opt.termguicolors = true
opt.cmdheight = 0
opt.cursorline = true
opt.conceallevel = 2
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldsep = " ", foldclose = "" }
opt.laststatus = 3
opt.showtabline = 0

-- Keyword definition (treat dash as part of word)
opt.iskeyword:append("-")
opt.iskeyword:append("@")
opt.iskeyword:append("48-57")
opt.iskeyword:append("_")
opt.iskeyword:append("192-255")

-- Format list pattern for text formatting
opt.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]

-- Splits
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "cursor"

-- Session
opt.sessionoptions = { "globals", "buffers", "tabpages", "folds", "winsize", "winpos", "curdir", "localoptions" }

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.infercase = true

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.softtabstop = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.linebreak = true
opt.breakindent = true
opt.breakindentopt = { "shift:2", "sbr" }
opt.breakat = " \t;:,!?"
opt.showbreak = "↪ "
opt.wrap = false

-- Folding (uses Treesitter)
opt.foldenable = true
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
if vim.fn.exists("v:lua._G.Devastion.misc.custom_foldtext") == 1 then
  opt.foldtext = "v:lua._G.Devastion.misc.custom_foldtext()"
end
opt.foldcolumn = "0"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldnestmax = 4

-- Scrolling
opt.scrolloff = 10
opt.smoothscroll = true

-- Backup, Undo and History
opt.swapfile = false
opt.backup = false
opt.writebackup = true
opt.undofile = true
opt.undolevels = 10000
opt.jumpoptions = "view"

-- Encoding and Spelling
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.spell = false
opt.spelloptions = { "camel", "noplainbuffer" }
opt.spelllang = { "en" }
