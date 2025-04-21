local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = augroup("highlight_yank", { clear = true }),
  callback = function() vim.highlight.on_yank() end,
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

-- TODO: Refactor TMux leader autocmd
local tmux_leader = vim.system({ "tmux", "show-options", "-g", "prefix" }, {}):wait().stdout:match("prefix%s+(%S+)")

local function unset_tmux_leader()
  if tmux_leader then
    vim.system({ "tmux", "set-option", "-g", "prefix", "None" }, {})
  end
end

local function reset_tmux_leader()
  if tmux_leader then
    vim.system({ "tmux", "set-option", "-g", "prefix", tmux_leader }, {})
  end
end

vim.api.nvim_create_user_command("ResetTmuxLeader", function()
  local leader = tmux_leader or "C-Space"
  vim.system({ "tmux", "set-option", "-g", "prefix", leader }, {})
  vim.notify("Leader set to C-Space", vim.log.levels.INFO, { title = "TMux" })
end, {})

autocmd({ "ModeChanged" }, {
  group = augroup("i_tmux_unset_leader", {}),
  desc = "Disable tmux leader in insert mode",
  callback = function(args)
    local new_mode = args.match:sub(-1)
    if new_mode == "i" then
      unset_tmux_leader()
    else
      reset_tmux_leader()
    end
  end,
})
