local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "lewis6991/gitsigns.nvim",
    data = {
      config = function()
        require("gitsigns").setup({
          numhl = true,
          signs = {
            add = { text = "+" },
            change = { text = "~" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
          },
          on_attach = function(bufnr)
            -- Navigation
            map("]h", function()
              if vim.wo.diff then
                vim.cmd.normal({ "]h", bang = true })
              else
                require("gitsigns").nav_hunk("next")
              end
            end, "Next Hunk", "n", { buffer = bufnr })

            map("[h", function()
              if vim.wo.diff then
                vim.cmd.normal({ "[h", bang = true })
              else
                require("gitsigns").nav_hunk("prev")
              end
            end, "Prev Hunk", "n", { buffer = bufnr })

            -- Hunk actions
            map("<leader>ghs", function()
              require("gitsigns").stage_hunk()
            end, "Stage Hunk", "n", { buffer = bufnr })

            map("<leader>ghs", function()
              require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, "Stage Hunk", "v", { buffer = bufnr })

            map("<leader>ghr", function()
              require("gitsigns").reset_hunk()
            end, "Reset Hunk", "n", { buffer = bufnr })

            map("<leader>ghr", function()
              require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, "Reset Hunk", "v", { buffer = bufnr })

            map("<leader>ghu", function()
              require("gitsigns").undo_stage_hunk()
            end, "Undo Stage Hunk", "n", { buffer = bufnr })

            -- Buffer actions
            map("<leader>ghS", function()
              require("gitsigns").stage_buffer()
            end, "Stage Buffer", "n", { buffer = bufnr })

            map("<leader>ghR", function()
              require("gitsigns").reset_buffer()
            end, "Reset Buffer", "n", { buffer = bufnr })

            -- Preview / diff
            map("<leader>ghp", function()
              require("gitsigns").preview_hunk()
            end, "Preview Hunk", "n", { buffer = bufnr })

            map("<leader>gti", function()
              require("gitsigns").preview_hunk_inline()
            end, "Preview Hunk [i]nline", "n", { buffer = bufnr })

            map("<leader>ghd", function()
              require("gitsigns").diffthis()
            end, "Diff vs index", "n", { buffer = bufnr })

            map("<leader>ghD", function()
              require("gitsigns").diffthis("@")
            end, "Diff vs Last Commit", "n", { buffer = bufnr })

            -- Blame
            map("<leader>ghb", function()
              require("gitsigns").blame_line()
            end, "Blame Line", "n", { buffer = bufnr })

            map("<leader>ghB", function()
              require("gitsigns").blame()
            end, "Blame Buffer", "n", { buffer = bufnr })

            -- Lists
            map("<leader>ghq", function()
              require("gitsigns").setqflist()
            end, "Quickfix Hunks", "n", { buffer = bufnr })

            map("<leader>ghQ", function()
              require("gitsigns").setqflist("all")
            end, "Quickfix Hunks (all)", "n", { buffer = bufnr })

            -- Toggles
            map("<leader>gtb", function()
              require("gitsigns").toggle_current_line_blame()
            end, "Toggle Blame Line", "n", { buffer = bufnr })

            map("<leader>gtw", function()
              require("gitsigns").toggle_word_diff()
            end, "Toggle Word Diff", "n", { buffer = bufnr })

            -- Text object
            map("ih", function()
              require("gitsigns").select_hunk()
            end, "Hunk", { "o", "x" }, { buffer = bufnr })
          end,
        })
      end,
    },
  },
})
