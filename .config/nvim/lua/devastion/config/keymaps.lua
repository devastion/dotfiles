local map = vim.keymap.set

map("x", "D", '"_d', { desc = "Delete without yanking" })

-- Allow moving the cursor through wrapped lines with j, k
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "$", "v:count == 0 ? 'g$' : '$'", { desc = "End of Line", expr = true, silent = true })
map({ "n", "x" }, "0", "v:count == 0 ? 'g0' : '0'", { desc = "Start of Line", expr = true, silent = true })

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
map("n", "<leader><tab>$", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>0", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>l", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>h", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<leader><tab>r", function()
  vim.ui.input({ prompt = "Tab Name: " }, function(name)
    vim.schedule(function()
      vim.api.nvim_tabpage_set_var(0, "name", name or vim.api.nvim_tabpage_get_number(0))
      vim.schedule(function() vim.cmd.redrawtabline() end)
    end)
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

map("n", "<C-a><C-a>", function() require("devastion.utils.common").toggles() end, { desc = "Increment" })
map("n", "<C-a><C-x>", function() require("devastion.utils.common").toggles(true) end, { desc = "Decrement" })
map("n", "<C-a><C-d>", function() print(vim.fn.expand("<cword>")) end, { desc = "Print <cword>" })

map("n", "<leader>l", function() require("lazy.view").show("home") end, { desc = "Lazy" })

map("n", "<leader>fn", function()
  local path = require("devastion.utils.path").get_root_directory()
  vim.ui.input({ prompt = "New file name: ", default = path .. "/" }, function(input)
    if input and input ~= "" then
      vim.cmd("edit " .. vim.fn.fnameescape(input))
    end
  end)
end, { desc = "New File (root)" })

map("n", "<leader>fN", function()
  local path = require("devastion.utils.path").buffer_dir()
  vim.ui.input({ prompt = "New file name: ", default = path .. "/" }, function(input)
    if input and input ~= "" then
      vim.cmd("edit " .. vim.fn.fnameescape(input))
    end
  end)
end, { desc = "New File (cwd)" })
