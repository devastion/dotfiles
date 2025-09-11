MiniDeps.later(function()
  MiniDeps.add({ source = "akinsho/git-conflict.nvim" })

  require("git-conflict").setup({
    default_mappings = false,
    default_commands = true,
    disable_diagnostics = false,
  })

  vim.keymap.set("n", "]x", function() require("git-conflict").find_next("ours") end, { desc = "Next Conflict" })
  vim.keymap.set("n", "]x", function() require("git-conflict").find_prev("ours") end, { desc = "Prev Conflict" })
  vim.keymap.set(
    "n",
    "<leader>gxx",
    function() require("which-key").show({ keys = "<leader>gx", loop = true }) end,
    { desc = "Hydra Mode" }
  )
  vim.keymap.set(
    "n",
    "<leader>gxn",
    function() require("git-conflict").find_next("ours") end,
    { desc = "Next Conflict" }
  )
  vim.keymap.set(
    "n",
    "<leader>gxp",
    function() require("git-conflict").find_prev("ours") end,
    { desc = "Prev Conflict" }
  )
  vim.keymap.set("n", "<leader>gxo", function() require("git-conflict").choose("ours") end, { desc = "Choose Ours" })
  vim.keymap.set(
    "n",
    "<leader>gxt",
    function() require("git-conflict").choose("theirs") end,
    { desc = "Choose Theirs" }
  )
  vim.keymap.set("n", "<leader>gxb", function() require("git-conflict").choose("both") end, { desc = "Choose Both" })
  vim.keymap.set("n", "<leader>gx0", function() require("git-conflict").choose("none") end, { desc = "Choose None" })
  vim.keymap.set("n", "<leader>gxq", function() vim.cmd("GitConflictListQf") end, { desc = "Quickfix List" })
  vim.keymap.set("n", "<leader>gxr", function() vim.cmd("GitConflictRefresh") end, { desc = "Refresh Conflicts" })
end)
