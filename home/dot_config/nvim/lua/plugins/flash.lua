vim.pack.add({
  'https://github.com/folke/flash.nvim',
}, { confirm = false })

local flash = require('flash')

---@type Flash.Config
flash.setup({
  search = {
    multi_window = false,
  },
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
        opts.autohide = opts.autohide
          or (
            vim.fn.mode(true):find('no')
            and (
              vim.v.operator == 'y'
              or vim.v.operator == 'd'
              or vim.v.operator == 'g@'
            )
          )

        opts.jump_labels = opts.jump_labels
          and vim.v.count == 0
          and vim.fn.reg_executing() == ''
          and vim.fn.reg_recording() == ''
          and vim.fn.mode(true):find('o') == nil
      end,
      keys = { 'f', 'F', 't', 'T' },
      char_actions = function(motion)
        return {
          [motion:lower()] = 'next',
          [motion:upper()] = 'prev',
        }
      end,
    },
  },
  highlight = {
    backdrop = false,
  },
  prompt = {
    enabled = false,
  },
})

vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
  require('flash').treesitter({
    actions = {
      ['<Tab>'] = 'next',
      ['<S-Tab>'] = 'prev',
    },
  })
end, { desc = 'Flash treesitter selection' })

vim.keymap.set('n', '<leader>*', function()
  flash.jump({ pattern = vim.fn.expand('<cword>') })
end, { desc = 'Jump with current word' })

local function char2()
  local Flash = require('flash')

  ---@param flash_opts Flash.Format
  local function format(flash_opts)
    -- always show first and second label
    return {
      { flash_opts.match.label1, 'FlashMatch' },
      { flash_opts.match.label2, 'FlashLabel' },
    }
  end

  Flash.jump({
    search = { mode = 'search' },
    label = {
      after = false,
      before = { 0, 0 },
      uppercase = false,
      format = format,
    },
    pattern = [[\<]],
    action = function(match, state)
      state:hide()
      Flash.jump({
        search = { max_length = 0 },
        highlight = { matches = false },
        label = { format = format },
        matcher = function(win)
          -- limit matches to the current label
          return vim.tbl_filter(function(m)
            return m.label == match.label and m.win == win
          end, state.results)
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
end

require('which-key').add({
  '<leader>j',
  char2,
  desc = 'Flash jump (2 chars)',
  icon = ' ',
})
