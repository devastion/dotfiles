local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup

autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = augroup("highlight_on_yank"),
  callback = function()
    vim.hl.on_yank({ timeout = 200, visual = true })
  end,
})

autocmd("BufRead", {
  desc = "Change vim.o.scroll",
  group = augroup("set_scroll"),
  callback = function()
    vim.schedule(function()
      if vim.o.scroll > 10 then
        vim.o.scroll = 10
      end
    end)
  end,
})

autocmd("BufReadPost", {
  desc = "Restore cursor to last location",
  group = augroup("cursor_last_loc"),
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

autocmd("FileType", {
  desc = "Disable new line comment continuation",
  group = augroup("disable_new_line_comments"),
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function(event)
    vim.schedule(function()
      vim.wo[vim.fn.bufwinid(event.buf)].wrap = true
      vim.wo[vim.fn.bufwinid(event.buf)].spell = true
    end)
  end,
})

autocmd("ColorScheme", {
  desc = "Set WinSeparator highlight on colorscheme change",
  group = augroup("win_separator_hl"),
  callback = function()
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#7aa2f7" })
  end,
})

-- Apply immediately for the initial colorscheme
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#7aa2f7" })

local cursorline_group = augroup("cursorline_active_window")

autocmd({ "InsertLeave", "WinEnter" }, {
  desc = "Show cursor line in active window",
  group = cursorline_group,
  callback = function()
    if vim.w.auto_cursorline then
      vim.wo.cursorline = true
      vim.w.auto_cursorline = nil
    end
  end,
})

autocmd({ "InsertEnter", "WinLeave" }, {
  desc = "Hide cursor line in inactive window",
  group = cursorline_group,
  callback = function()
    if vim.wo.cursorline then
      vim.w.auto_cursorline = true
      vim.wo.cursorline = false
    end
  end,
})

autocmd("FileType", {
  desc = "Close some filetypes with <q>",
  group = augroup("close_with_q"),
  pattern = {
    "checkhealth",
    "help",
    "notify",
    "qf",
    "grug-far",
    "gitsigns-blame",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "dap-float",
    "nvim-pack",
    "dap-repl",
    "dap-view",
    "dap-view-term",
    "dap-view-help",
    "octo",
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

autocmd("VimResized", {
  desc = "Resize splits if window got resized",
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

if vim.env.TMUX then
  local function get_tmux_leader()
    if not vim.g.tmux_leader_key then
      vim.g.tmux_leader_key = vim.system({ "tmux", "show", "-gv", "prefix" }, {}):wait().stdout:match("%S+")
    end
    return vim.g.tmux_leader_key
  end

  autocmd("ModeChanged", {
    group = augroup("i_tmux_unset_leader"),
    desc = "Disable TMux prefix in insert/command mode",
    callback = function(event)
      local new_mode = event.match:sub(-1)
      vim.schedule(function()
        if new_mode == "i" or new_mode == "c" then
          vim.system({ "tmux", "set-option", "-p", "prefix", "None" }, {})
        else
          vim.system({ "tmux", "set-option", "-p", "prefix", get_tmux_leader() }, {})
        end
      end)
    end,
  })
end

autocmd("SourcePost", {
  group = augroup("notify_project_config"),
  pattern = { ".nvim.lua", ".nvimrc", ".exrc" },
  desc = "Notify when project config is sourced",
  callback = function(event)
    vim.schedule(function()
      vim.notify("Loaded project config: " .. event.file, vim.log.levels.INFO)
    end)
  end,
})

autocmd("PackChanged", {
  group = augroup("pack_changed"),
  pattern = "*",
  callback = function(event)
    local p = event.data
    local task = (p.spec.data or {}).task
    if p.kind ~= "delete" and type(task) == "function" then
      pcall(task, p)

      vim.notify("Updated " .. p.spec.name, vim.log.levels.INFO)
    end
  end,
})

if not package.loaded["snacks.words"] then
  local lsp_reference_highlight_group = augroup("lsp_reference_highlight")

  -- IDE like highlight when stopping cursor
  autocmd("CursorMoved", {
    group = lsp_reference_highlight_group,
    desc = "Highlight references under cursor",
    callback = function()
      -- Only run if the cursor is not in insert mode
      if vim.fn.mode() ~= "i" then
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local supports_highlight = false
        for _, client in ipairs(clients) do
          if client.server_capabilities.documentHighlightProvider then
            supports_highlight = true
            break -- Found a supporting client, no need the check others
          end
        end

        -- 3. Proceed only if an LSP is active AND supports the feature
        if supports_highlight then
          vim.lsp.buf.clear_references()
          vim.lsp.buf.document_highlight()
        end
      end
    end,
  })

  -- IDE like highlight when stopping cursor
  vim.api.nvim_create_autocmd("CursorMovedI", {
    group = lsp_reference_highlight_group,
    desc = "Clear highlights when entering insert mode",
    callback = function()
      vim.lsp.buf.clear_references()
    end,
  })
end

vim.api.nvim_create_autocmd("CursorHold", {
  desc = "Show diagnostics on hover",
  callback = function()
    vim.diagnostic.open_float(nil, {
      focus = false,
      border = vim.g.border_style,
    })
  end,
})
