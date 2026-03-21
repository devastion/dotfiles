local cmd_exists = require("devastion.utils").cmd_exists
local map = require("devastion.utils").map
local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup

require("devastion.utils.pkg").add({
  {
    src = "xvzc/chezmoi.nvim",
    data = {
      config = function()
        require("chezmoi").setup({})

        autocmd({ "BufRead", "BufNewFile" }, {
          group = augroup("chezmoi"),
          pattern = {
            os.getenv("HOME") .. "/.local/share/chezmoi/*",
            os.getenv("HOME") .. "/.dotfiles/*",
          },
          callback = function(ev)
            local bufnr = ev.buf
            local edit_watch = function()
              require("chezmoi.commands.__edit").watch(bufnr)
            end
            vim.schedule(edit_watch)
          end,
        })

        if cmd_exists("chezmoi") then
          map("<leader>fC", function()
            require("chezmoi.pick").fzf()
          end, "Chezmoi Files")
        end
      end,
    },
  },
})
