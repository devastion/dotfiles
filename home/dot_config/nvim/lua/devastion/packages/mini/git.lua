local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup
local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "nvim-mini/mini-git",
    data = {
      config = function()
        require("mini.git").setup()

        map("<Leader>gA", function()
          vim.cmd("Git add " .. vim.fn.expand("%:p"))
        end, "Add File")

        map("<Leader>gR", function()
          vim.cmd("Git reset " .. vim.fn.expand("%:p"))
        end, "Reset File")
      end,
    },
  },
})

autocmd("FileType", {
  desc = "Use mini.git as foldexpr for git, gitcommit and diff",
  group = augroup("mini_git"),
  pattern = { "git", "gitcommit", "diff" },
  callback = function()
    vim.wo.foldexpr = "v:lua.MiniGit.diff_foldexpr()"
    vim.wo.foldmethod = "expr"
  end,
})
