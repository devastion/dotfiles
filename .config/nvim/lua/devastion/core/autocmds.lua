local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = augroup("highlight_yank", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

autocmd({ "FileType" }, {
  desc = "Change vim.o.scroll, disable new line comment etc",
  group = augroup("global_file_tweaks", { clear = true }),
  pattern = { "*" },
  callback = function()
    vim.o.formatoptions = "jqlc"
    if vim.o.scroll > 10 then
      vim.o.scroll = 10
    end
  end,
})

autocmd({ "BufWritePre" }, {
  desc = "Auto create dir when saving a file, in case some intermediate directory does not exist",
  group = augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

autocmd("FileType", {
  desc = "Wrap and check for spell in text filetypes",
  group = augroup("wrap_spell", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit" },
  callback = function()
    vim.wo.wrap = true
    vim.wo.spell = true
  end,
})

autocmd({ "InsertLeave", "WinEnter" }, {
  desc = "Show cursor line only in active window",
  callback = function()
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#7aa2f7" })
    if vim.w.auto_cursorline then
      vim.wo.cursorline = true
      vim.w.auto_cursorline = nil
    end
  end,
})

autocmd({ "InsertEnter", "WinLeave" }, {
  desc = "Show cursor line only in active window",
  callback = function()
    if vim.wo.cursorline then
      vim.w.auto_cursorline = true
      vim.wo.cursorline = false
    end
  end,
})

autocmd("FileType", {
  desc = "Close some filetypes with <q>",
  group = augroup("close_with_q", { clear = true }),
  pattern = {
    "checkhealth",
    "grug-far",
    "help",
    "notify",
    "qf",
    "gitsigns-blame",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "dap-float",
    "mininotify-history",
    "nvim-pack",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
        noremap = true,
      })
    end)
  end,
})

autocmd({ "VimResized" }, {
  desc = "Resize splits if window got resized",
  group = augroup("resize_splits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

autocmd("BufReadPost", {
  group = augroup("last_loc", { clear = true }),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].cursor_last_loc then
      return
    end
    vim.b[buf].cursor_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd({ "ModeChanged" }, {
  group = vim.api.nvim_create_augroup("i_tmux_unset_leader", {}),
  desc = "Disable TMux leader in insert mode",
  callback = function(args)
    local new_mode = args.match:sub(-1)
    local function get_tmux_leader()
      if not vim.g.tmux_leader_key then
        vim.g.tmux_leader_key = vim.system({ "tmux", "show", "-gv", "prefix" }, {}):wait().stdout:match("%S+")
      end

      return vim.g.tmux_leader_key
    end

    if new_mode == "i" then
      vim.system({ "tmux", "set-option", "-p", "prefix", "None" }, {})
    else
      vim.system({ "tmux", "set-option", "-p", "prefix", get_tmux_leader() }, {})
    end
  end,
})

autocmd("BufWritePost", {
  pattern = "*",
  callback = function(event)
    local file = vim.fn.expand("%:p")
    if vim.fn.filereadable(file) == 1 and vim.fn.filewritable(file) == 1 then
      local first_line = vim.fn.getline(1)
      if first_line:match("^#!") then
        vim.keymap.set("n", "<leader>cx", function()
          vim.fn.system({ "chmod", "+x", vim.fn.expand("%:p") })
          print("Made " .. vim.fn.expand("%:t") .. " executable")
        end, { desc = "Chmod +x current file", buffer = event.buf })
      end
    end
  end,
})

autocmd("PackChanged", {
  pattern = "*",
  callback = function(event)
    local p = event.data
    local post_update = (p.spec.data or {}).post_update

    if p.kind ~= "delete" and type(post_update) == "function" then
      pcall(post_update, p)
    end
  end,
})

autocmd("SourcePost", {
  pattern = { ".nvim.lua", ".nvimrc", ".exrc" },
  callback = function(args) vim.notify("Loaded project config: " .. args.file, vim.log.levels.INFO) end,
})
