vim.pack.add({
  'https://github.com/Wansmer/treesj',
}, { confirm = false })

local loaded = false

local function treesj_toggle()
  if not loaded then
    require('treesj').setup({
      use_default_keymaps = false,
      max_join_length = 500,
    })
    loaded = true
  end
  require('treesj').toggle()
end

vim.keymap.set(
  'n',
  'J',
  treesj_toggle,
  { desc = 'Toggle Split/Join', silent = true }
)
