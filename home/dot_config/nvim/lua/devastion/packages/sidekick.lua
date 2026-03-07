local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "folke/sidekick.nvim",
    data = {
      init = function()
        vim.g.sidekick_nes = false
      end,
      config = function()
        require("sidekick").setup({
          cli = {
            win = {
              layout = "float",
            },
            mux = {
              backend = "tmux",
              enabled = true,
            },
          },
        })

        map("<C-.>", function()
          require("sidekick.cli").toggle()
        end, "Sidekick Toggle", { "n", "t", "i", "x" })

        map("<Leader>aa", function()
          require("sidekick.cli").toggle()
        end, "Sidekick Toggle CLI")

        map("<Leader>as", function()
          require("sidekick.cli").select({ filter = { installed = true } })
        end, "Select CLI")

        map("<Leader>ad", function()
          require("sidekick.cli").close()
        end, "Detach a CLI Session")

        map("<Leader>at", function()
          require("sidekick.cli").send({ msg = "{this}" })
        end, "Send This", { "x", "n" })

        map("<Leader>af", function()
          require("sidekick.cli").send({ msg = "{file}" })
        end, "Send File")

        map("<Leader>av", function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end, "Send Visual Selection", { "x" })

        map("<Leader>ap", function()
          require("sidekick.cli").prompt()
        end, "Sidekick Select Prompt", { "n", "x" })
      end,
    },
  },
})
