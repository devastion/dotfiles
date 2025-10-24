local map = vim.g.remap

map("D", '"_d', "Delete without yanking", "x")

-- Allow moving the cursor through wrapped lines with j, k
map("j", "v:count == 0 ? 'gj' : 'j'", "Down", { "n", "x" }, { expr = true, silent = true })
map("k", "v:count == 0 ? 'gk' : 'k'", "Up", { "n", "x" }, { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("<c-h>", "<c-w>h", "Go to Left Window", "n", { remap = true })
map("<c-j>", "<c-w>j", "Go to Lower Window", "n", { remap = true })
map("<c-k>", "<c-w>k", "Go to Upper Window", "n", { remap = true })
map("<c-l>", "<c-w>l", "Go to Right Window", "n", { remap = true })

-- Resize window using <ctrl> arrow keys
map("<c-Up>", function()
  local height = vim.api.nvim_win_get_height(0)
  vim.api.nvim_win_set_height(0, height + 2)
end, "Increase Window Height")
map("<c-Down>", function()
  local height = vim.api.nvim_win_get_height(0)
  vim.api.nvim_win_set_height(0, height - 2)
end, "Decrease Window Height")
map("<c-Left>", function()
  local width = vim.api.nvim_win_get_width(0)
  vim.api.nvim_win_set_width(0, width + 2)
end, "Increase Window Width")
map("<c-Right>", function()
  local width = vim.api.nvim_win_get_width(0)
  vim.api.nvim_win_set_width(0, width - 2)
end, "Decrease Window Width")

-- Buffers
map("<leader>`", function()
  pcall(vim.cmd.e, "#")
end, "Switch to Previous Buffer")
map("<leader>bb", function()
  pcall(vim.cmd.e, "#")
end, "Switch to Other Buffer")
map("<leader>bd", function()
  pcall(vim.cmd("bd"))
end, "Delete Buffer")
map("<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end, "Close Other Buffers")
map("<leader>bn", function()
  vim.cmd.enew()
end, "New File")
map("<leader>b0", function()
  vim.cmd("bfirst")
end, "First Buffer")
map("<leader>b$", function()
  vim.cmd("blast")
end, "Last Buffer")
map("]b", function()
  vim.cmd("bnext")
end, "Next Buffer")
map("[b", function()
  vim.cmd("bprev")
end, "Previous Buffer")

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
map("<leader><tab>r", function()
  vim.ui.input({ prompt = "Tab Name: " }, function(name)
    local current_tab = vim.api.nvim_get_current_tabpage()
    if name then
      vim.g["TabPageCustomName" .. current_tab] = name
      vim.schedule(function()
        vim.api.nvim_tabpage_set_var(0, "name", name)
        vim.schedule(function()
          vim.cmd.redrawtabline()
        end)
      end)
    else
      vim.g["TabPageCustomName" .. current_tab] = nil
    end
  end)
end, "Rename Tab")

-- Commenting and Indenting
map("gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Below")
map("gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", "Add Comment Above")

-- Better Indenting
map("<", "<gv", nil, "v")
map(">", ">gv", nil, "v")

-- Increments, Diagnostics, and Toggles
map("<tab>", function()
  require("devastion.helpers.misc").word_cycle()
end, "Cycle Words")
map("<s-tab>", function()
  require("devastion.helpers.misc").word_cycle(true)
end, "Cycle Words")

-- Diagnostics
map("<leader>cd", function()
  vim.diagnostic.open_float({ border = vim.g.ui_border })
end, "Line Diagnostics")
map("<leader>cq", function()
  vim.diagnostic.setqflist({ border = vim.g.ui_border })
end, "Diagnostics to QF")

-- Add undo break-points
map(",", ",<c-g>u", nil, "i")
map(".", ".<c-g>u", nil, "i")
map(";", ";<c-g>u", nil, "i")

-- Disable the spacebar key's default behavior in Normal and Visual modes
map("<space>", "<nop>", nil, { "n", "v" }, { silent = true })

-- Disable arrow keys in normal mode
map("<left>", "", nil, "n")
map("<right>", "", nil, "n")
map("<up>", "", nil, "n")
map("<down>", "", nil, "n")

-- lazy.nvim
map("<leader>L", function()
  require("lazy.view").show("home")
end, "Lazy")
