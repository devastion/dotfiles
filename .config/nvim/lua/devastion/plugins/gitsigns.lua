---@type LazySpec
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
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
      local wk = require("which-key")

      wk.add({ "<leader>gh", group = "+[Hunks]" })
      wk.add({ "<leader>gt", group = "+[Toggles]" })

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]h", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, { desc = "Next Hunk" })

      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[h", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, { desc = "Prev Hunk" })

      -- Visual Mode
      map(
        "v",
        "<leader>ghs",
        function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
        { desc = "Stage Hunk" }
      )
      map(
        "v",
        "<leader>ghr",
        function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
        { desc = "Reset Hunk" }
      )

      -- Normal Mode
      map("n", "<leader>ghs", function() gitsigns.stage_hunk() end, { desc = "Stage Hunk" })
      map("n", "<leader>ghr", function() gitsigns.reset_hunk() end, { desc = "Reset Hunk" })
      map("n", "<leader>ghS", function() gitsigns.stage_buffer() end, { desc = "Stage Buffer" })
      map("n", "<leader>ghu", function() gitsigns.undo_stage_hunk() end, { desc = "Undo stage hunk" })
      map("n", "<leader>ghR", function() gitsigns.reset_buffer() end, { desc = "Unstage Buffer" })
      map("n", "<leader>ghp", function() gitsigns.preview_hunk() end, { desc = "Preview Hunk" })
      map("n", "<leader>ghb", function() gitsigns.blame_line() end, { desc = "Blame Line" })
      map("n", "<leader>ghd", function() gitsigns.diffthis() end, { desc = "Diff Against Index" })
      map("n", "<leader>ghD", function() gitsigns.diffthis("@") end, { desc = "Diff Against Last Commit" })

      -- Toggles
      map("n", "<leader>gtb", function() gitsigns.toggle_current_line_blame() end, { desc = "Blame Line" })
      map("n", "<leader>gtd", function() gitsigns.toggle_deleted() end, { desc = "Show Deleted" })
      map("n", "<leader>gtw", function() gitsigns.toggle_word_diff() end, { desc = "Word Diff" })

      -- Text object
      map({ "o", "x" }, "ih", function() gitsigns.select_hunk() end, { desc = "Hunk" })
    end,
  },
}
