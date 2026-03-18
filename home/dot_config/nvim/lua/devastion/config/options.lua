local o = vim.o
local opt = vim.opt

-- ═══════════════════════════════════════════════════════════════════════
-- Editor Behavior
-- ═══════════════════════════════════════════════════════════════════════
o.mouse = ""
o.updatetime = 250
o.timeoutlen = 300
o.ttimeoutlen = 0
o.autowrite = true
o.autowriteall = true
o.confirm = true
o.virtualedit = "block"
o.exrc = true
opt.path:append("**")

-- ═══════════════════════════════════════════════════════════════════════
-- Clipboard & Completion
-- ═══════════════════════════════════════════════════════════════════════
o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- ═══════════════════════════════════════════════════════════════════════
-- Command Line
-- ═══════════════════════════════════════════════════════════════════════
o.wildmode = "longest:full,full"
opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- ═══════════════════════════════════════════════════════════════════════
-- UI & Appearance
-- ═══════════════════════════════════════════════════════════════════════
o.background = "dark"
o.signcolumn = "yes"
o.number = true
o.relativenumber = true
o.cursorline = true
o.showmode = false
o.showcmd = false
o.ruler = false
o.cmdheight = 0
o.laststatus = 3
o.showtabline = 0
o.conceallevel = 2
o.list = true
o.winborder = vim.g.border_style
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = "",
  foldsep = " ",
  foldclose = "",
}

-- ═══════════════════════════════════════════════════════════════════════
-- Windows & Splits
-- ═══════════════════════════════════════════════════════════════════════
o.splitbelow = true
o.splitright = true
o.splitkeep = "cursor"
o.switchbuf = "usetab"
opt.sessionoptions = { "globals", "buffers", "tabpages", "folds", "winsize", "winpos", "curdir", "localoptions" }

-- ═══════════════════════════════════════════════════════════════════════
-- Search
-- ═══════════════════════════════════════════════════════════════════════
o.ignorecase = true
o.smartcase = true
o.infercase = true
o.hlsearch = false

-- ═══════════════════════════════════════════════════════════════════════
-- Indentation & Wrapping
-- ═══════════════════════════════════════════════════════════════════════
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.shiftround = true
o.expandtab = true
o.smartindent = true
o.wrap = false
o.linebreak = true
o.breakindent = true
o.showbreak = "↪ "
o.breakat = " \t;:,!?"
opt.breakindentopt = { "shift:2", "sbr" }

-- ═══════════════════════════════════════════════════════════════════════
-- Folding
-- ═══════════════════════════════════════════════════════════════════════
o.foldenable = true
o.foldmethod = "expr"
o.foldcolumn = "0"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldnestmax = 20
o.foldtext = "v:lua.require'devastion.utils'.foldtext()"

-- ═══════════════════════════════════════════════════════════════════════
-- Scrolling
-- ═══════════════════════════════════════════════════════════════════════
o.scrolloff = 10
o.sidescrolloff = 8
o.smoothscroll = true

-- ═══════════════════════════════════════════════════════════════════════
-- Files & Persistence
-- ═══════════════════════════════════════════════════════════════════════
o.swapfile = false
o.backup = false
o.writebackup = false
o.undofile = true
o.undolevels = 10000
o.jumpoptions = "view"
o.shadafile = vim.fn.stdpath("cache") .. "/custom_shada/" .. vim.fn.sha256(vim.fn.getcwd()):sub(1, 8) .. ".shada"

-- ═══════════════════════════════════════════════════════════════════════
-- Spelling & Text Formatting
-- ═══════════════════════════════════════════════════════════════════════
opt.spelloptions = { "camel", "noplainbuffer" }
o.spelllang = "en_us"
o.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
opt.iskeyword:append("-")
opt.diffopt:append("linematch:60")
o.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]
