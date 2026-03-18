local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup

require("devastion.utils.pkg").add({
  {
    src = "nvim-treesitter/nvim-treesitter",
    version = "main",
    data = {
      init = function()
        require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
          local filename = vim.fs.basename(vim.api.nvim_buf_get_name(tonumber(bufnr) or 0))
          return string.match(filename, ".*mise.*%.toml$") ~= nil
        end, { force = true, all = false })
      end,
      task = function()
        vim.schedule(function()
          vim.notify("Updating treesitter parsers...", vim.log.levels.INFO)
          require("nvim-treesitter.install").update(nil, { summary = true })
          vim.notify("Treesitter parsers updated!", vim.log.levels.INFO)
        end)
      end,
    },
  },
  {
    src = "nvim-treesitter/nvim-treesitter-textobjects",
    version = "main",
    data = {
      config = function()
        require("nvim-treesitter-textobjects").setup({
          select = {
            lookahead = true,
            include_surrounding_whitespace = false,
          },
          move = {
            set_jumps = true,
          },
        })
      end,
    },
  },
  {
    src = "nvim-treesitter/nvim-treesitter-context",
    data = {
      config = function()
        require("treesitter-context").setup({
          multiwindow = true,
        })
      end,
    },
  },
  {
    src = "windwp/nvim-ts-autotag",
    data = {
      event = { "BufReadPost", "BufWritePost", "BufNewFile" },
      config = function()
        require("nvim-ts-autotag").setup()
      end,
    },
  },
  {
    src = "nicolas-martin/region-folding.nvim",
    data = {
      disabled = true,
      event = { "BufReadPost", "BufNewFile" },
      config = function()
        require("region-folding").setup({
          region_text = { start = "#region", ending = "#endregion" },
          fold_indicator = "",
        })
      end,
    },
  },
  "rrethy/nvim-treesitter-endwise",
})

local ts = require("nvim-treesitter")

-- State tracking for async parser loading
local parsers_loaded = {}
local parsers_pending = {}
local parsers_failed = {}

local ns = vim.api.nvim_create_namespace("treesitter.async")

--stylua: ignore
local ts_install_filetypes = { "bash", "c", "comment", "css", "diff", "dockerfile", "gitcommit", "gitignore", "html", "ini", "javascript", "jsdoc", "json", "lua", "luadoc", "luap", "make", "markdown", "markdown_inline", "nginx", "proto", "python", "query", "regex", "rust", "scss", "sql", "terraform", "toml", "tsx", "typescript", "vim", "vimdoc", "xml", "yaml", "zig" }

local ts_ignore_filetypes = { "checkhealth", "mason" }

autocmd("BufEnter", {
  group = augroup("nvim_treesitter_install_parsers"),
  once = true,
  callback = function()
    ts.install(ts_install_filetypes, { max_jobs = 8, generate = true })
  end,
})

local function attach_ts_textobjects(buf)
  local installed_parsers = require("nvim-treesitter").get_installed()

  local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
  if not vim.tbl_contains(installed_parsers, ft) then
    return
  end

  for _, map in ipairs({
    { { "x", "o" }, "af", "@function.outer" },
    { { "x", "o" }, "if", "@function.inner" },
    { { "x", "o" }, "ab", "@block.outer" },
    { { "x", "o" }, "ib", "@block.inner" },
    { { "x", "o" }, "ac", "@class.outer" },
    { { "x", "o" }, "ic", "@class.inner" },
    { { "x", "o" }, "aC", "@conditional.outer" },
    { { "x", "o" }, "iC", "@conditional.inner" },
    { { "x", "o" }, "aa", "@parameter.outer" },
    { { "x", "o" }, "ia", "@parameter.inner" },
    { { "x", "o" }, "aA", "@assignment.outer" },
    { { "x", "o" }, "iA", "@assignment.inner" },
    { { "x", "o" }, "al", "@loop.outer" },
    { { "x", "o" }, "il", "@loop.inner" },
    { { "x", "o" }, "ad", "@comment.outer" },
    { { "x", "o" }, "id", "@comment.inner" },
    { { "x", "o" }, "as", "@statement.outer" },
  }) do
    vim.keymap.set(map[1], map[2], function()
      require("nvim-treesitter-textobjects.select").select_textobject(map[3], "textobjects")
    end, { desc = "Select " .. map[3], buffer = buf })
  end

  local moves = {
    goto_next_start = {
      ["]f"] = "@function.outer",
      ["]c"] = "@class.outer",
      ["]a"] = "@parameter.inner",
      ["]r"] = "@return.outer",
      ["]l"] = "@loop.outer",
    },
    goto_next_end = {
      ["]F"] = "@function.outer",
      ["]C"] = "@class.outer",
      ["]A"] = "@parameter.inner",
      ["]R"] = "@return.outer",
      ["]L"] = "@loop.outer",
    },
    goto_previous_start = {
      ["[f"] = "@function.outer",
      ["[c"] = "@class.outer",
      ["[a"] = "@parameter.inner",
      ["[r"] = "@return.outer",
      ["[l"] = "@loop.outer",
    },
    goto_previous_end = {
      ["[F"] = "@function.outer",
      ["[C"] = "@class.outer",
      ["[A"] = "@parameter.inner",
      ["[R"] = "@return.outer",
      ["[L"] = "@loop.outer",
    },
  }

  for method, keymaps in pairs(moves) do
    for key, query in pairs(keymaps) do
      local queries = type(query) == "table" and query or { query }
      local parts = {}
      for _, q in ipairs(queries) do
        local part = q:gsub("@", ""):gsub("%..*", "")
        part = part:sub(1, 1):upper() .. part:sub(2)
        table.insert(parts, part)
      end
      local desc = table.concat(parts, " or ")
      desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
      desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
      if not (vim.wo.diff and key:find("[cC]")) then
        vim.keymap.set({ "n", "x", "o" }, key, function()
          require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
        end, {
          buffer = buf,
          desc = desc,
          silent = true,
        })
      end
    end
  end

  local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
  vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move, { buffer = buf })
  vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite, { buffer = buf })
  -- vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
  -- vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
  -- vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
  -- vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

  vim.keymap.set("n", "<localleader>a", function()
    require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
  end, { desc = "Swap @parameter with next", buffer = buf })
  vim.keymap.set("n", "<localleader>A", function()
    require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
  end, { desc = "Swap @parameter with previous", buffer = buf })
end

-- Helper to start highlighting and indentation
local function start(buf, lang)
  local ok = pcall(vim.treesitter.start, buf, lang)
  if ok then
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldmethod = "expr"
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    attach_ts_textobjects(buf)
  end
  return ok
end

-- Decoration provider for async parser loading
vim.api.nvim_set_decoration_provider(ns, {
  on_start = vim.schedule_wrap(function()
    if #parsers_pending == 0 then
      return false
    end
    for _, data in ipairs(parsers_pending) do
      if vim.api.nvim_buf_is_valid(data.buf) then
        if start(data.buf, data.lang) then
          parsers_loaded[data.lang] = true
        else
          parsers_failed[data.lang] = true
        end
      end
    end
    parsers_pending = {}
  end),
})

-- Auto-install parsers and enable highlighting on FileType
autocmd("FileType", {
  group = augroup("nvim_treesitter_start"),
  desc = "Enable treesitter highlighting and indentation (non-blocking)",
  callback = function(event)
    if vim.bo.filetype == "" or vim.tbl_contains(ts_ignore_filetypes, event.match) then
      return
    end

    local lang = vim.treesitter.language.get_lang(event.match) or event.match
    local buf = event.buf

    if not lang or not require("nvim-treesitter.parsers")[lang] then
      return
    end

    if parsers_failed[lang] then
      return
    end

    if parsers_loaded[lang] then
      -- Parser already loaded, start immediately (fast path)
      start(buf, lang)
    else
      -- Queue for async loading
      table.insert(parsers_pending, { buf = buf, lang = lang })
    end

    -- Auto-install missing parsers (async, no-op if already installed)
    ts.install({ lang })
  end,
})
