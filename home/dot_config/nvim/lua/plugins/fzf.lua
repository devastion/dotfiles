vim.pack.add({
  'https://github.com/ibhagwan/fzf-lua',
}, { confirm = false })

local fzf = require('fzf-lua')
local icons = require('config.icons')

local actions = fzf.actions

local M = {}

local PROMPT = icons.ui('telescope', 'right')

---@param opts table?
---@return table
local function open(opts)
  return vim.tbl_deep_extend('force', {
    prompt = PROMPT,
    winopts = {
      preview = {
        layout = 'flex',
        horizontal = 'right:50%',
        vertical = 'up:50%',
        wrap = true,
      },
    },
  }, opts or {})
end

---@param opts table?
---@return table
local function dropdown(opts)
  return vim.tbl_deep_extend('force', {
    prompt = PROMPT,
    winopts = {
      height = 0.70,
      width = 0.65,
      preview = { hidden = true, layout = 'vertical', vertical = 'down:30%' },
    },
  }, opts or {})
end

---@param opts table?
---@return table
local function cursor_dropdown(opts)
  return dropdown(vim.tbl_deep_extend('force', {
    fzf_opts = { ['--wrap'] = true },
    winopts = {
      relative = 'cursor',
      row = 1,
      col = 0,
      height = 0.35,
      width = 0.5,
      preview = {
        hidden = true,
        layout = 'flex',
        horizontal = 'right:50%',
        vertical = 'up:50%',
        wrap = true,
      },
    },
  }, opts or {}))
end

---@return string
local function buf_dir()
  local name = vim.api.nvim_buf_get_name(0)
  local dir = name ~= '' and vim.uv.fs_stat(name) and vim.fs.dirname(name)
  return dir or assert(vim.uv.cwd())
end

---@return table
local function in_buf_dir()
  return { cwd = buf_dir() }
end

---@param name string
---@return fun()
local function command(name)
  return function()
    vim.cmd(name)
  end
end

---@param name string
---@param opts table|(fun():table)|nil
---@return fun(extra: table?)
local function picker(name, opts)
  return function(extra)
    local fn = fzf[name]
    if type(fn) ~= 'function' then
      vim.notify('fzf-lua: unknown picker ' .. name, vim.log.levels.ERROR)
      return
    end
    local resolved
    if type(opts) == 'function' then
      resolved = opts()
    else
      resolved = vim.deepcopy(opts)
    end
    if extra then
      resolved = vim.tbl_deep_extend('force', resolved or {}, extra)
    end
    return fn(resolved)
  end
end

---@param spec table
---@return table<string, fun(extra: table?)>
local function pickers(spec)
  local group = {}
  for _, name in ipairs(spec) do
    group[name] = picker(name)
  end
  for name, entry in pairs(spec) do
    if type(name) == 'string' then
      if type(entry) == 'function' then
        group[name] = entry
      elseif type(entry) == 'table' then
        group[name] = picker(entry[1], entry[2])
      else
        group[name] = picker(entry)
      end
    end
  end
  return group
end

-- errors and warnings only
local SEVERITY = { severity_limit = vim.diagnostic.severity.WARN }

M.api = {
  find = pickers({
    'args',
    'awesome_colorschemes',
    'buffers',
    'colorschemes',
    'filetypes',
    'files',
    'git_files',
    'global',
    'history',
    'profiles',
    'search_history',
    'tabs',
    recent_files = 'oldfiles',
    bbuffers = { 'buffers', in_buf_dir },
    bfiles = { 'files', in_buf_dir },
    git_bfiles = { 'git_files', in_buf_dir },
    emoji = command('Emoji'),
    gitmoji = command('Gitmoji'),
    nerd_icons = command('NerdIcons'),
    unicode = command('Unicode'),
  }),
  search = pickers({
    'autocmds',
    'blines',
    'builtin',
    'changes',
    'command_history',
    'commands',
    'grep_last',
    'grep_quickfix',
    'grep_visual',
    'help_tags',
    'highlights',
    'jumps',
    'keymaps',
    'lgrep_quickfix',
    'lines',
    'loclist',
    'loclist_stack',
    'man_pages',
    'marks',
    'quickfix',
    'quickfix_stack',
    'registers',
    'resume',
    'serverlist',
    'spell_suggest',
    'spellcheck',
    'tags',
    'tagstack',
    'tmux_buffers',
    'treesitter',
    'undotree',
    'zoxide',
    options = 'nvim_options',
    grep = 'live_grep',
    grep_glob = 'live_grep_glob',
    grep_buffer = 'lgrep_curbuf',
    grep_word = 'grep_cword',
    grep_WORD = 'grep_cWORD',
    tags_buffer = 'btags',
    diagnostics_document = { 'diagnostics_document', SEVERITY },
    diagnostics_workspace = { 'diagnostics_workspace', SEVERITY },
  }),
  lsp = pickers({
    code_actions = 'lsp_code_actions',
    declarations = 'lsp_declarations',
    definitions = 'lsp_definitions',
    document_diagnostics = 'lsp_document_diagnostics',
    document_symbols = 'lsp_document_symbols',
    finder = 'lsp_finder',
    implementations = 'lsp_implementations',
    incoming_calls = 'lsp_incoming_calls',
    live_workspace_symbols = 'lsp_live_workspace_symbols',
    outgoing_calls = 'lsp_outgoing_calls',
    references = 'lsp_references',
    type_sub = 'lsp_type_sub',
    type_super = 'lsp_type_super',
    typedefs = 'lsp_typedefs',
    workspace_diagnostics = 'lsp_workspace_diagnostics',
    workspace_symbols = 'lsp_workspace_symbols',
  }),
  git = pickers({
    blame = 'git_blame',
    blog = 'git_bcommits',
    branches = 'git_branches',
    diff = 'git_diff',
    hunks = 'git_hunks',
    log = 'git_commits',
    reflog = 'git_reflog',
    stash = 'git_stash',
    status = 'git_status',
    tags = 'git_tags',
    worktrees = 'git_worktrees',
  }),
}

function M.setup()
  fzf.setup({
    { 'hide' },
    prompt = PROMPT,
    keymap = {
      builtin = {
        true,
        ['<C-n>'] = 'down',
        ['<C-p>'] = 'up',

        ['<F1>'] = 'toggle-preview',
        ['<F2>'] = 'toggle-preview-wrap',
        ['<F12>'] = 'toggle-fullscreen',

        ['<c-f>'] = 'preview-page-down',
        ['<c-b>'] = 'preview-page-up',

        ['<m-j>'] = 'preview-down',
        ['<m-k>'] = 'preview-up',
      },
      fzf = {
        ['ctrl-a'] = 'beginning-of-line',
        ['ctrl-e'] = 'end-of-line',

        ['ctrl-b'] = 'backward-char',
        ['ctrl-f'] = 'forward-char',

        ['alt-b'] = 'backward-word',
        ['alt-f'] = 'forward-word',

        ['ctrl-w'] = 'backward-kill-word',
        ['alt-d'] = 'kill-word',

        ['ctrl-n'] = 'down',
        ['ctrl-p'] = 'up',
        ['ctrl-j'] = 'down',
        ['ctrl-k'] = 'up',

        ['ctrl-up'] = 'previous-history',
        ['ctrl-down'] = 'next-history',

        ['ctrl-d'] = 'half-page-down',
        ['ctrl-u'] = 'half-page-up',

        ['tab'] = 'toggle',

        ['ctrl-l'] = 'clear-query',
        ['ctrl-y'] = 'execute-silent(echo {+} | pbcopy)',

        ['ctrl-x'] = 'jump',

        ['alt-j'] = 'preview-down',
        ['alt-k'] = 'preview-up',
      },
    },
    fzf_colors = true,
    fzf_opts = {
      ['--info'] = 'default',
      ['--reverse'] = true,
      ['--scrollbar'] = '▓',
      ['--ellipsis'] = icons.ui.ellipsis,
    },
    defaults = {
      file_icons = 'mini',
      formatter = 'path.dirname_first',
      preview_pager = false,
    },
    previewers = { builtin = { toggle_behavior = 'extend' } },
    ---@diagnostic disable-next-line: assign-type-mismatch
    winopts = function()
      local compact = vim.o.columns < 160
      return {
        width = compact and 0.95 or 0.80,
        height = compact and 0.95 or 0.80,
        row = 0.5,
        col = 0.5,
      }
    end,
    files = open({
      cwd_prompt = false,
      winopts = { title = (' %s Files '):format(icons.fs.file) },
    }),
    grep = open({
      RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH,
      hidden = true,
      fzf_opts = { ['--keep-right'] = '' },
      winopts = { title = (' %s Grep '):format(icons.fs.files) },
    }),
    lsp = {
      symbols = {
        symbol_style = 1,
        symbol_icons = icons.kinds,
      },
      code_actions = cursor_dropdown({
        winopts = { title = { { ' Code Actions ', '@type' } } },
      }),
    },
    oldfiles = dropdown({
      cwd_only = true,
      include_current_session = true,
      winopts = {
        title = (' %s Recent Files '):format(icons.fs.file),
      },
    }),
    diagnostics = dropdown({
      winopts = {
        title = {
          { (' %s Diagnostics '):format(icons.lsp.error), 'DiagnosticError' },
        },
      },
    }),
    undotree = open({
      previewer = 'undotree_native',
      locate = true,
      winopts = { title = ' Undotree ' },
    }),
    autocmds = open({
      previewer = 'hide',
      winopts = { title = ' Autocommands ' },
    }),
    marks = cursor_dropdown({
      marks = '%a',
      winopts = {
        title = ' Marks ',
        preview = {
          hidden = false,
        },
      },
    }),
    jumps = dropdown({
      winopts = { title = ' Jumps ', preview = { hidden = false } },
    }),
    changes = dropdown({
      prompt = '',
      winopts = { title = ' Changes ', preview = { hidden = false } },
    }),
    highlights = { winopts = { title = ' Highlights ' } },
    helptags = { winopts = { title = ' Help ' } },
    buffers = dropdown({
      fzf_opts = { ['--delimiter'] = ' ', ['--with-nth'] = '-1..' },
      winopts = { title = (' %s Buffers '):format(icons.fs.files) },
    }),
    keymaps = dropdown({
      winopts = { title = ' Keymaps ', width = 0.7 },
    }),
    registers = cursor_dropdown({
      winopts = { title = ' Registers ', width = 0.6 },
    }),
    git = {
      files = dropdown({
        path_shorten = false,
        cmd = 'git ls-files --others --cached --exclude-standard',
        winopts = { title = (' %s Git Files '):format(icons.git.logo) },
      }),
      branches = dropdown({
        winopts = {
          title = (' %s Branches '):format(icons.git.branch),
          height = 0.3,
          row = 0.4,
        },
      }),
      status = open({
        prompt = '',
        winopts = { title = (' %s Git Status '):format(icons.git.logo) },
        actions = {
          ['right'] = { fn = actions.git_unstage, reload = true },
          ['left'] = { fn = actions.git_stage, reload = true },
          ['ctrl-x'] = { fn = actions.git_reset, reload = true },
        },
      }),
      bcommits = open({
        prompt = '',
        winopts = { title = ' Buffer Commits ' },
      }),
      commits = open({
        prompt = '',
        winopts = { title = ' Commits ' },
      }),
      icons = {
        ['M'] = { icon = icons.git.change, color = 'yellow' },
        ['D'] = { icon = icons.git.delete, color = 'red' },
        ['A'] = { icon = icons.git.add, color = 'green' },
        ['R'] = { icon = icons.git.renamed, color = 'yellow' },
        ['C'] = { icon = icons.git.conflict, color = 'yellow' },
        ['T'] = { icon = icons.git.renamed, color = 'magenta' },
        ['?'] = { icon = icons.git.untracked, color = 'magenta' },
      },
    },
  })

  fzf.register_ui_select({ prompt = PROMPT })

  ---@param mode string|string[]
  ---@param specs table<string, [fun(), string]>
  local function map(mode, specs)
    for lhs, spec in pairs(specs) do
      vim.keymap.set(mode, lhs, spec[1], { desc = spec[2] })
    end
  end

  local find, search, lsp, git = M.api.find, M.api.search, M.api.lsp, M.api.git

  map('n', {
    ['<leader>:'] = { search.command_history, 'Command history' },
    ['<leader>U'] = { search.undotree, 'Undotree' },
    ['<leader><space>'] = { find.global, 'Global finder' },

    ['<leader>ff'] = { find.files, 'Files (cwd)' },
    ['<leader>fF'] = { find.bfiles, 'Files (buffer dir)' },
    ['<leader>fg'] = { find.git_files, 'Git files (cwd)' },
    ['<leader>fG'] = { find.git_bfiles, 'Git files (buffer dir)' },
    ['<leader>fb'] = { find.buffers, 'Buffers (cwd)' },
    ['<leader>fB'] = { find.bbuffers, 'Buffers (buffer dir)' },
    ['<leader>fr'] = { find.recent_files, 'Recent files' },
    ['<leader>ft'] = { find.filetypes, 'File types' },
    ['<leader>f<tab>'] = { find.tabs, 'Tabs' },
    ['<leader>fi'] = { find.nerd_icons, 'Nerd icons' },
    ['<leader>fu'] = { find.unicode, 'Unicode characters' },
    ['<leader>fe'] = { find.emoji, 'Emoji' },
    ['<leader>fm'] = { find.gitmoji, 'Gitmoji' },
    ['<leader>fa'] = { find.args, 'Argument list' },
    ['<leader>fp'] = { find.profiles, 'Fzf profiles' },
    ['<leader>fc'] = { find.colorschemes, 'Colorschemes' },
    ['<leader>fC'] = { find.awesome_colorschemes, 'Awesome colorschemes' },
    ['<leader>fh'] = { find.search_history, 'Search history' },
    ['<leader>fH'] = { find.history, 'File history' },

    ['<leader>sg'] = { search.grep, 'Live grep' },
    ['<leader>sG'] = { search.grep_glob, 'Live grep (glob)' },
    ["<leader>s'"] = { search.marks, 'Marks' },
    ['<leader>s"'] = { search.registers, 'Registers' },
    ["<leader>'"] = { search.marks, 'Marks' },
    ['<leader>"'] = { search.registers, 'Registers' },
    ['<leader>sa'] = { search.autocmds, 'Autocommands' },
    ['<leader>sb'] = { search.grep_buffer, 'Grep buffer' },
    ['<leader>sB'] = { search.builtin, 'Builtin commands' },
    ['<leader>sc'] = { search.commands, 'Commands' },
    ['<leader>sC'] = { search.changes, 'Changes' },
    ['<leader>sd'] = { search.diagnostics_workspace, 'Diagnostics (all)' },
    ['<leader>sD'] = { search.diagnostics_document, 'Diagnostics (buffer)' },
    ['<leader>sh'] = { search.help_tags, 'Help tags' },
    ['<F1>'] = { search.help_tags, 'Help tags' },
    ['<leader>sH'] = { search.highlights, 'Highlights' },
    ['<leader>sj'] = { search.jumps, 'Jumps' },
    ['<leader>sk'] = { search.keymaps, 'Keymaps' },
    ['<leader>sl'] = { search.loclist, 'Location list' },
    ['<leader>sL'] = { search.loclist_stack, 'Location list stack' },
    ['<leader>sM'] = { search.man_pages, 'Man pages' },
    ['<leader>so'] = { search.options, 'Neovim options' },
    ['<leader>ss'] = { search.treesitter, 'Treesitter symbols' },
    ['<leader>sS'] = { lsp.document_symbols, 'Document symbols' },
    ['<leader>sy'] = { lsp.workspace_symbols, 'Workspace symbols' },
    ['<leader>sY'] = { lsp.live_workspace_symbols, 'Live workspace symbols' },
    ['<leader>sf'] = { lsp.finder, 'LSP finder' },
    ['<leader>st'] = { search.tagstack, 'Tag stack' },
    ['<leader>sT'] = { search.tags, 'Tag list' },
    ['<leader>sF'] = { search.tags_buffer, 'Buffer tags' },
    ['<leader>sq'] = { search.quickfix, 'Quickfix list' },
    ['<leader>sQ'] = { search.quickfix_stack, 'Quickfix stack' },
    ['<leader>s;'] = { search.grep_quickfix, 'Grep quickfix' },
    ['<leader>s,'] = { search.lgrep_quickfix, 'Live grep quickfix' },
    ['<leader>sr'] = { search.resume, 'Resume' },
    ['<leader>sR'] = { search.grep_last, 'Repeat grep' },
    ['<leader>sw'] = { search.grep_word, 'Grep word' },
    ['<leader>sW'] = { search.grep_WORD, 'Grep WORD' },
    ['<leader>sz'] = { search.zoxide, 'Zoxide' },
    ['<leader>s/'] = { search.blines, 'Buffer lines' },
    ['<leader>s?'] = { search.lines, 'Open buffer lines' },
    ['<leader>s='] = { search.spell_suggest, 'Spell suggest' },
    ['<leader>s!'] = { search.spellcheck, 'Spellcheck' },
    ['<leader>sm'] = { search.tmux_buffers, 'Tmux buffers' },
    ['<leader>sv'] = { search.serverlist, 'LSP servers' },

    ['<leader>gb'] = { git.blame, 'Blame' },
    ['<leader>gB'] = { git.branches, 'Branches' },
    ['<leader>gs'] = { git.status, 'Status' },
    ['<leader>gS'] = { git.stash, 'Stash' },
    ['<leader>gl'] = { git.log, 'Log' },
    ['<leader>gL'] = { git.blog, 'Log (file)' },
    ['<leader>gt'] = { git.tags, 'Tags' },
    ['<leader>gd'] = { git.diff, 'Diff' },
    ['<leader>gH'] = { git.hunks, 'Hunks' },
    ['<leader>gw'] = { git.worktrees, 'Worktrees' },
    ['<leader>gF'] = { git.reflog, 'Reflog' },
  })

  map('x', {
    ['<leader>sg'] = { search.grep_visual, 'Visual grep' },
  })
end

return M
