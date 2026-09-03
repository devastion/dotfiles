vim.pack.add({
  'https://github.com/lewis6991/gitsigns.nvim',
}, { confirm = false })

local gitsigns = require('gitsigns')
local icons = require('config.icons')

gitsigns.setup({
  numhl = true,
  attach_to_untracked = true,
  signs = {
    add = { text = icons.git.add },
    change = { text = icons.git.change },
    delete = { text = icons.git.delete },
    topdelete = { text = icons.git.delete },
    changedelete = { text = icons.git.change },
    untracked = { text = icons.git.untracked },
  },
  signs_staged = {
    add = { text = icons.git.add },
    change = { text = icons.git.change },
    delete = { text = icons.git.delete },
    topdelete = { text = icons.git.delete },
    changedelete = { text = icons.git.change },
    untracked = { text = icons.git.untracked },
  },
  on_attach = function(bufnr)
    ---@param mode string|string[]
    ---@param lhs string
    ---@param rhs string|function
    ---@param desc string
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(
        mode,
        lhs,
        rhs,
        { desc = desc, buf = bufnr, silent = true }
      )
    end

    map('n', ']h', function()
      if vim.wo.diff then
        vim.cmd.normal({ ']h', bang = true })
      else
        gitsigns.nav_hunk('next')
      end
    end, 'Next Git Hunk')

    map('n', ']H', function()
      if vim.wo.diff then
        vim.cmd.normal({ ']H', bang = true })
      else
        gitsigns.nav_hunk('next', { target = 'staged' })
      end
    end, 'Next Git Hunk (staged)')

    map('n', '[h', function()
      if vim.wo.diff then
        vim.cmd.normal({ '[h', bang = true })
      else
        gitsigns.nav_hunk('prev')
      end
    end, 'Previous Git Hunk')

    map('n', '[H', function()
      if vim.wo.diff then
        vim.cmd.normal({ '[H', bang = true })
      else
        gitsigns.nav_hunk('prev', { target = 'staged' })
      end
    end, 'Previous Git Hunk (staged)')

    map('n', '<leader>ghs', gitsigns.stage_hunk, 'Stage Hunk')
    map('n', '<leader>ghr', gitsigns.reset_hunk, 'Reset Hunk')
    map('n', '<leader>ghS', gitsigns.stage_buffer, 'Stage Buffer')
    map('n', '<leader>ghR', gitsigns.reset_buffer, 'Reset Buffer')
    map('n', '<leader>ghp', gitsigns.preview_hunk, 'Preview Hunk')
    map('n', '<leader>ghb', function()
      gitsigns.blame_line({ full = true })
    end, 'Git Blame Line')
    map('n', '<leader>ghd', gitsigns.diffthis, 'Git diff this')
    map('n', '<leader>ghD', function()
      gitsigns.diffthis('~')
    end, 'Git Diff This (~)')

    map('v', '<leader>ghs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, 'Stage Selected Lines')
    map('v', '<leader>ghr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, 'Reset Selected Lines')

    map(
      'n',
      '<leader>gub',
      gitsigns.toggle_current_line_blame,
      'Toggle git blame line'
    )
    map('n', '<leader>gud', gitsigns.preview_hunk_inline, 'Preview hunk inline')
    map('n', '<leader>guw', gitsigns.toggle_word_diff, 'Toggle git word diff')

    map({ 'o', 'x' }, 'ih', ':<C-u>Gitsigns select_hunk<CR>', 'Select Git Hunk')
  end,
})
