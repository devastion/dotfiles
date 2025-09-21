local o = vim.o

-- General
o.mouse = ""
o.updatetime = 250
o.timeoutlen = 300
o.autowrite = true
o.autowriteall = true
o.autoread = true
o.confirm = true
o.tabclose = "uselast"
o.clipboard = "unnamedplus"
o.completeopt = "menu,menuone,noselect,fuzzy"

-- INFO: Run .nvim.lua .nvimrc .exrc (per directory config)
o.exrc = true
o.secure = true

-- Sign Column
o.signcolumn = "yes"
o.number = true
o.relativenumber = true

-- UI
o.background = "dark"
o.showmode = false
o.showcmd = false
o.termguicolors = true
o.cmdheight = 0
o.cursorline = true
o.conceallevel = 2
o.list = true
o.listchars = "tab:» ,trail:·,nbsp:␣,"
o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldclose:"
o.laststatus = 3
o.showtabline = 0

-- Splits
o.splitbelow = true
o.splitright = true

-- Session
o.sessionoptions = "globals,buffers,tabpages,folds,winsize,winpos,curdir,localoptions"

-- Search
o.ignorecase = true
o.smartcase = true
o.hlsearch = false
o.infercase = true

-- Indentation
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true
o.autoindent = true
o.smartindent = true
o.linebreak = true
o.breakindent = true
o.breakindentopt = "shift:2,sbr"
o.breakat = " \t;:,!?"
o.showbreak = "↪ "
o.wrap = false

-- Folding
o.foldenable = true
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = "v:lua.vim.g.custom_foldtext()"
o.foldcolumn = "0"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldnestmax = 4

-- Scrolling
o.scroll = 10
o.scrolloff = 10
o.smoothscroll = true

-- Backup, Undo and History
o.swapfile = false
o.backup = false
o.writebackup = false
o.undofile = true
o.undolevels = 10000

-- Encoding and Spelling
o.encoding = "utf-8"
o.fileencoding = "utf-8"
o.spell = false
o.spelloptions = "camel,noplainbuffer"
o.spelllang = "en"
