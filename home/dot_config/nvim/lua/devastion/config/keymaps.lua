local map = require("devastion.utils").map
local pkg = require("devastion.utils.pkg")

map("D", '"_d', "Delete without yanking", "x")
map("p", '"_dP', "Paste without yanking", "v")

-- Allow moving the cursor through wrapped lines with j, k
map("j", "v:count == 0 ? 'gj' : 'j'", "Down", { "n", "x" }, { expr = true, silent = true })
map("k", "v:count == 0 ? 'gk' : 'k'", "Up", { "n", "x" }, { expr = true, silent = true })

-- Buffers
map("<leader>`", function()
  pcall(vim.cmd.e, "#")
end, "Switch to Previous Buffer")
map("<leader>bb", function()
  pcall(vim.cmd.e, "#")
end, "Switch to Other Buffer")
map("<leader>bd", function()
  pcall(vim.cmd, "bd")
end, "Delete Buffer")
map("<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end, "Close Other Buffers")
map("<leader>bn", vim.cmd.enew, "New File")
map("<leader>b0", vim.cmd.bfirst, "First Buffer")
map("<leader>b$", vim.cmd.blast, "Last Buffer")
map("]b", vim.cmd.bnext, "Next Buffer")
map("[b", vim.cmd.bprev, "Previous Buffer")

-- Tabs
map("<leader><tab>$", vim.cmd.tablast, "Last Tab")
map("<leader><tab>0", vim.cmd.tabfirst, "First Tab")
map("<leader><tab>n", vim.cmd.tabnew, "New Tab")
map("<leader><tab><tab>", vim.cmd.tabnew, "New Tab")
map("<leader><tab>d", vim.cmd.tabclose, "Close Tab")
map("<leader><tab>o", vim.cmd.tabonly, "Close Other Tabs")
map("<leader><tab>l", vim.cmd.tabnext, "Next Tab")
map("]<tab>", vim.cmd.tabnext, "Next Tab")
map("<leader><tab>h", vim.cmd.tabprevious, "Previous Tab")
map("[<tab>", vim.cmd.tabprevious, "Previous Tab")

-- Commenting and Indenting
map("gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Below")
map("gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Above")

-- Better Indenting
map("<", "<gv", nil, "v")
map(">", ">gv", nil, "v")

-- Add undo break-points
map(",", ",<c-g>u", nil, "i")
map(".", ".<c-g>u", nil, "i")
map(";", ";<c-g>u", nil, "i")

-- Disable the spacebar key's default behavior in Normal and Visual modes
map("<space>", "<nop>", nil, { "n", "v" }, { silent = true })

-- Disable arrow keys in normal mode
map("<left>", "<nop>", nil, "n")
map("<right>", "<nop>", nil, "n")
map("<up>", "<nop>", nil, "n")
map("<down>", "<nop>", nil, "n")

-- Select all
map("==", "gg<S-v>G", "Select all")
map("<A-a>", "ggVG", "Select all", "n", { silent = true })

-- Line start / end
map("gl", "$", "Go to end of line")
map("gh", "^", "Go to start of line")

-- vim.pack
map("<leader>Pd", pkg.uninstall, "Uninstall Package")
map("<leader>PD", pkg.prune, "Prune Inactive Packages")
map("<leader>Pu", pkg.update, "Update Package")
map("<leader>PU", pkg.updateAll, "Update All Packages")

-- Toggles
map("<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify((vim.wo.wrap and "Enabled" or "Disabled") .. " line wrap", vim.log.levels.INFO)
end, "Toggle Line Wrap")
map("<leader>ul", function()
  vim.wo.number = not vim.wo.number
  vim.notify((vim.wo.number and "Enabled" or "Disabled") .. " relative line number", vim.log.levels.INFO)
end, "Toggle Relative Line Number")
map("<leader>us", function()
  vim.wo.spell = not vim.wo.spell
  vim.notify((vim.wo.spell and "Enabled" or "Disabled") .. " spelling", vim.log.levels.INFO)
end, "Toggle Spelling")
map("<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled(), { bufnr = vim.api.nvim_get_current_buf() })
  vim.notify((vim.diagnostic.is_enabled() and "Enabled" or "Disabled") .. " diagnostics (buffer)", vim.log.levels.INFO)
end, "Toggle Diagnostics (buffer)")
map("<leader>uD", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
  vim.notify((vim.diagnostic.is_enabled() and "Enabled" or "Disabled") .. " diagnostics (global)", vim.log.levels.INFO)
end, "Toggle Diagnostics (global)")
map("<leader>uv", function()
  vim.diagnostic.config({
    virtual_lines = not vim.diagnostic.config().virtual_lines,
  })
end, "Toggle Virtual Lines")
