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

autocmd("BufNewFile", {
  group = augroup("templates", {}),
  desc = "Use templates for files",
  pattern = "*.*",
  callback = function()
    local template_path = require("devastion.utils.path").get_template_path()
    local file = io.open(template_path, "r")
    if not file then
      return
    end

    local lines = {}
    local author = "Dimitar Banev"
    local date = os.date("%Y-%m-%d")

    for line in file:lines() do
      line = line:gsub("<DATE>", date):gsub("<AUTHOR>", author)
      table.insert(lines, line)
    end
    file:close()

    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)

    -- INFO: Add execute permission to the user for shell files
    if vim.bo.filetype == "sh" then
      vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = 0,
        once = true,
        callback = function() vim.fn.system({ "chmod", "u+x", vim.api.nvim_buf_get_name(0) }) end,
      })
    end
  end,
})

require("devastion.utils.tmux").setup()

vim.api.nvim_create_user_command("RestoreTabPagesName", function()
  local tabs = vim.api.nvim_list_tabpages()

  for i, _t in ipairs(tabs) do
    local custom_name = vim.g["TabPageCustomName" .. i]
    if custom_name and custom_name ~= "" then
      vim.api.nvim_tabpage_set_var(i, "name", custom_name)
    end
  end
end, {
  desc = "Restore Tab Pages Name",
})

autocmd("BufReadPost", {
  group = augroup("last_loc", { clear = true }),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
