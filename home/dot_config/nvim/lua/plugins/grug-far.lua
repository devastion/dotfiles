vim.pack.add({
  'https://github.com/MagicDuck/grug-far.nvim',
}, { confirm = false })

local grug = require('grug-far')
grug.setup({
  headerMaxWidth = 80,
})

vim.keymap.set({ 'n', 'v' }, '<leader>cr', function()
  local ext = vim.bo.buftype == '' and vim.fn.expand('%:e')

  grug.open({
    transient = true,
    prefills = {
      filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
    },
  })
end, { desc = 'Search and replace' })

local function files_grug_far_replace()
  local cur_entry_path = require('mini.files').get_fs_entry().path
  local prefills = { paths = vim.fs.dirname(cur_entry_path) }

  if not grug.has_instance('explorer') then
    grug.open({
      instanceName = 'explorer',
      prefills = prefills,
      staticTitle = 'Find and Replace from Explorer',
    })
  else
    grug.get_instance('explorer'):open()
    grug.get_instance('explorer'):update_input_values(prefills, false)
  end
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    vim.keymap.set(
      'n',
      'gs',
      files_grug_far_replace,
      { buf = args.data.buf_id, desc = 'Search in directory' }
    )
  end,
  desc = 'Map grug-far in MiniFiles buffers.',
})
