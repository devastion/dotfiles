---@type LazySpec
return {
  "akinsho/git-conflict.nvim",
  version = "*",
  opts = {
    default_mappings = {
      ours = "co",
      theirs = "ct",
      none = "c0",
      both = "cb",
      next = "n",
      prev = "p",
    },
    default_commands = true,
    disable_diagnostics = false,
  },
  -- config = function(_, opts)
  --   local git_conflict = require("git-conflict")
  --   git_conflict.setup(opts)
  --   local function map(bufnr)
  --     local function nmap(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc }) end
  --
  --     nmap("n", function() require("git-conflict").find_next("ours") end, "Next Conflict")
  --     nmap("p", function() require("git-conflict").find_prev("ours") end, "Previous Conflict")
  --     nmap("co", function() require("git-conflict").choose("ours") end, "Choose Ours")
  --     nmap("ct", function() require("git-conflict").choose("theirs") end, "Choose Theirs")
  --     nmap("cb", function() require("git-conflict").choose("both") end, "Choose Both")
  --     nmap("c0", function() require("git-conflict").choose("none") end, "Choose None")
  --     vim.b[bufnr].conflict_mappings_set = true
  --   end
  --
  --   ---@param key string
  --   ---@param mode "'n'|'v'|'o'|'nv'|'nvo'"?
  --   ---@return boolean
  --   local function is_mapped(key, mode) return vim.fn.hasmapto(key, mode or "n") > 0 end
  --
  --   local function unmap(bufnr)
  --     if not bufnr or not vim.b[bufnr].conflict_mappings_set then
  --       return
  --     end
  --     if is_mapped("co") then
  --       vim.api.nvim_buf_del_keymap(bufnr, "n", "co")
  --     end
  --     if is_mapped("cb") then
  --       vim.api.nvim_buf_del_keymap(bufnr, "n", "cb")
  --     end
  --     if is_mapped("c0") then
  --       vim.api.nvim_buf_del_keymap(bufnr, "n", "c0")
  --     end
  --     if is_mapped("ct") then
  --       vim.api.nvim_buf_del_keymap(bufnr, "n", "ct")
  --     end
  --     if is_mapped("n") then
  --       vim.api.nvim_buf_del_keymap(bufnr, "n", "n")
  --     end
  --     if is_mapped("p") then
  --       vim.api.nvim_buf_del_keymap(bufnr, "n", "p")
  --     end
  --     vim.b[bufnr].conflict_mappings_set = false
  --   end
  --
  --   vim.api.nvim_create_autocmd("User", {
  --     group = vim.api.nvim_create_augroup("git_conflict", {}),
  --     pattern = "GitConflictDetected",
  --     callback = function()
  --       vim.notify("Conflict detected in " .. vim.fn.expand("<afile>"))
  --       map(vim.api.nvim_get_current_buf())
  --     end,
  --   })
  --
  --   vim.api.nvim_create_autocmd("User", {
  --     group = vim.api.nvim_create_augroup("git_conflict", {}),
  --     pattern = "GitConflictResolved",
  --     callback = function() unmap(vim.api.nvim_get_current_buf()) end,
  --   })
  -- end,
  keys = {
    -- { "]x", function() require("git-conflict").find_next("ours") end, desc = "Next Conflict" },
    -- { "]x", function() require("git-conflict").find_prev("ours") end, desc = "Prev Conflict" },
    -- { "<leader>gxo", function() require("git-conflict").choose("ours") end, desc = "Choose Ours" },
    -- { "<leader>gxt", function() require("git-conflict").choose("theirs") end, desc = "Choose Theirs" },
    -- { "<leader>gxb", function() require("git-conflict").choose("both") end, desc = "Choose Both" },
    -- { "<leader>gx0", function() require("git-conflict").choose("none") end, desc = "Choose None" },
    { "]x", desc = "Next Conflict" },
    { "[x", desc = "Prev Conflict" },
    { "co", desc = "Choose Ours" },
    { "ct", desc = "Choose Theirs" },
    { "cb", desc = "Choose Both" },
    { "c0", desc = "Choose None" },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "GitConflictDetected",
      callback = function() vim.cmd("GitConflictListQf") end,
    })
  end,
}
