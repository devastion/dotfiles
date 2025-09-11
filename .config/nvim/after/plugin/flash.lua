MiniDeps.later(function()
  MiniDeps.add({ source = "folke/flash.nvim" })

  require("flash").setup({
    jump = {
      nohlsearch = true,
      autojump = true,
    },
    modes = {
      search = {
        enabled = true,
      },
      char = {
        jump_labels = true,
        config = function(opts)
          -- autohide flash when in operator-pending mode
          opts.autohide = opts.autohide
            or (
              vim.fn.mode(true):find("no")
              and (vim.v.operator == "y" or vim.v.operator == "d" or vim.v.operator == "g@")
            )

          -- disable jump labels when not enabled, when using a count,
          -- or when recording/executing registers
          opts.jump_labels = opts.jump_labels
            and vim.v.count == 0
            and vim.fn.reg_executing() == ""
            and vim.fn.reg_recording() == ""

          -- Show jump labels only in operator-pending mode
          opts.jump_labels = not vim.fn.mode(true):find("o")
        end,
        keys = { "f", "F", "t", "T" },
        char_actions = function(motion)
          return {
            [motion:lower()] = "next",
            [motion:upper()] = "prev",
          }
        end,
      },
    },
  })

  vim.keymap.set("n", "<leader><Space>", function()
    local flash = require("flash")

    local function format(opts)
      return {
        { opts.match.label1, "FlashMatch" },
        { opts.match.label2, "FlashLabel" },
      }
    end

    flash.jump({
      search = { mode = "search" },
      label = { after = false, before = { 0, 0 }, uppercase = false, format = format },
      pattern = [[\<]],
      action = function(match, state)
        state:hide()
        flash.jump({
          search = { max_length = 0 },
          highlight = { matches = false },
          label = { format = format },
          matcher = function(win)
            -- limit matches to the current label
            return vim.tbl_filter(function(m) return m.label == match.label and m.win == win end, state.results)
          end,
          labeler = function(matches)
            for _, m in ipairs(matches) do
              m.label = m.label2 -- use the second label
            end
          end,
        })
      end,
      labeler = function(matches, state)
        local labels = state:labels()
        for m, match in ipairs(matches) do
          match.label1 = labels[math.floor((m - 1) / #labels) + 1]
          match.label2 = labels[(m - 1) % #labels + 1]
          match.label = match.label1
        end
      end,
    })
  end, { desc = "Flash" })
end)
