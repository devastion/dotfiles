---@type LazySpec
return {
  "lewis6991/gitsigns.nvim",
  version = "*",
  opts = {
    numhl = true,
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local map = vim.g.remap

      map("]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]h", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, "Next Hunk", "n", { buffer = bufnr })

      map("[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[h", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, "Prev Hunk", "n", { buffer = bufnr })

      -- Visual Mode
      map("<leader>ghs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage Hunk", "v", { buffer = bufnr })
      map("<leader>ghr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset Hunk", "v", { buffer = bufnr })

      -- Normal Mode
      map("<leader>ghs", function()
        gitsigns.stage_hunk()
      end, "Stage Hunk", "n", { buffer = bufnr })
      map("<leader>ghr", function()
        gitsigns.reset_hunk()
      end, "Reset Hunk", "n", { buffer = bufnr })
      map("<leader>ghS", function()
        gitsigns.stage_buffer()
      end, "Stage Buffer", "n", { buffer = bufnr })
      map("<leader>ghu", function()
        gitsigns.stage_hunk()
      end, "Undo Stage Hunk", "n", { buffer = bufnr })
      map("<leader>ghR", function()
        gitsigns.reset_buffer()
      end, "Unstage Buffer", "n", { buffer = bufnr })
      map("<leader>ghp", function()
        gitsigns.preview_hunk()
      end, "Preview Hunk", "n", { buffer = bufnr })
      map("<leader>ghb", function()
        gitsigns.blame_line()
      end, "Blame Line", "n", { buffer = bufnr })
      map("<leader>ghB", function()
        gitsigns.blame()
      end, "Blame", "n", { buffer = bufnr })
      map("<leader>ghd", function()
        gitsigns.diffthis()
      end, "Diff Against Index", "n", { buffer = bufnr })
      map("<leader>ghD", function()
        gitsigns.diffthis("@")
      end, "Diff Against Last Commit", "n", { buffer = bufnr })
      map("<leader>ghq", function()
        gitsigns.setqflist()
      end, "Populate Quickfix", "n", { buffer = bufnr })
      map("<leader>ghQ", function()
        gitsigns.setqflist("all")
      end, "Populate Quickfix (all)", "n", { buffer = bufnr })

      -- Toggles
      map("<leader>gtb", function()
        gitsigns.toggle_current_line_blame()
      end, "Blame Line", "n", { buffer = bufnr })
      map("<leader>gti", function()
        gitsigns.preview_hunk_inline()
      end, "Preview Hunk Inline", "n", { buffer = bufnr })
      map("<leader>gtw", function()
        gitsigns.toggle_word_diff()
      end, "Word Diff", "n", { buffer = bufnr })

      -- Text object (operator-pending + visual)
      map("ih", function()
        gitsigns.select_hunk()
      end, "Hunk", { "o", "x" }, { buffer = bufnr })
    end,
  },
}
