vim.pack.add({ "https://github.com/christoomey/vim-tmux-navigator" }, { confirm = false })

vim.keymap.set("n", "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>")
vim.keymap.set("n", "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>")
vim.keymap.set("n", "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>")
vim.keymap.set("n", "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>")
vim.keymap.set("n", "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>")
