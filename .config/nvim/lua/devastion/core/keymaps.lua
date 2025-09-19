local map = vim.keymap.set

map("x", "D", '"_d', { desc = "Delete without yanking" })

-- Allow moving the cursor through wrapped lines with j, k
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- Disable the spacebar key's default behavior in Normal and Visual modes
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Disable arrow keys in normal mode
map("n", "<left>", "")
map("n", "<right>", "")
map("n", "<up>", "")
map("n", "<down>", "")

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", function()
  local height = vim.api.nvim_win_get_height(0)
  vim.api.nvim_win_set_height(0, height + 2)
end, { desc = "Increase Window Height" })
map("n", "<C-Down>", function()
  local height = vim.api.nvim_win_get_height(0)
  vim.api.nvim_win_set_height(0, height - 2)
end, { desc = "Decrease Window Height" })
map("n", "<C-Left>", function()
  local width = vim.api.nvim_win_get_width(0)
  vim.api.nvim_win_set_width(0, width + 2)
end, { desc = "Increase Window Width" })
map("n", "<C-Right>", function()
  local width = vim.api.nvim_win_get_width(0)
  vim.api.nvim_win_set_width(0, width - 2)
end, { desc = "Decrease Window Width" })

-- Tabs
map("n", "<leader><tab>$", vim.cmd.tablast, { desc = "Last Tab" })
map("n", "<leader><tab>0", vim.cmd.tabfirst, { desc = "First Tab" })
map("n", "<leader><tab>n", vim.cmd.tabnew, { desc = "New Tab" })
map("n", "<leader><tab><tab>", vim.cmd.tabnew, { desc = "New Tab" })
map("n", "<leader><tab>d", vim.cmd.tabclose, { desc = "Close Tab" })
map("n", "<leader><tab>o", vim.cmd.tabonly, { desc = "Close Other Tabs" })
map("n", "<leader><tab>l", vim.cmd.tabnext, { desc = "Next Tab" })
map("n", "]<tab>", vim.cmd.tabnext, { desc = "Next Tab" })
map("n", "<leader><tab>h", vim.cmd.tabprevious, { desc = "Previous Tab" })
map("n", "[<tab>", vim.cmd.tabprevious, { desc = "Previous Tab" })
map("n", "<leader><tab>r", function()
  vim.ui.input({ prompt = "Tab Name: " }, function(name)
    local current_tab = vim.api.nvim_get_current_tabpage()
    if name then
      vim.g["TabPageCustomName" .. current_tab] = name
      vim.schedule(function()
        vim.api.nvim_tabpage_set_var(0, "name", name)
        vim.schedule(function() vim.cmd.redrawtabline() end)
      end)
    else
      vim.g["TabPageCustomName" .. current_tab] = nil
    end
  end)
end, { desc = "Rename Tab" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Better Indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move towards the beginning/end of a line
map({ "n", "x" }, "H", "g^", { silent = true })
map({ "n", "x" }, "L", "g$", { silent = true })

map("n", "<C-a><C-a>", function() vim.g.word_cycle() end, { desc = "Increment" })
map("n", "<C-a><C-x>", function() vim.g.word_cycle(true) end, { desc = "Decrement" })

-- Buffers
map("n", "<leader>`", function() pcall(vim.cmd.e, "#") end, { desc = "Switch to Previous Buffer" })
map("n", "<leader>bb", function() pcall(vim.cmd.e, "#") end, { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function() pcall(vim.cmd("bd")) end, { desc = "Delete Buffer" })
map("n", "<leader>bn", function() vim.cmd.enew() end, { desc = "New File" })
map("n", "<leader>b0", function() vim.cmd("bfirst") end, { desc = "First Buffer" })
map("n", "<leader>b$", function() vim.cmd("blast") end, { desc = "Last Buffer" })

-- Diagnostics
map(
  "n",
  "<leader>cd",
  function() vim.diagnostic.open_float({ border = "single" }) end,
  { desc = "LSP: Line Diagnostics" }
)
map(
  "n",
  "<leader>cq",
  function() vim.diagnostic.setloclist({ border = "single" }) end,
  { desc = "LSP: Diagnostics to QF" }
)
