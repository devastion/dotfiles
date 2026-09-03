vim.g['chezmoi#use_tmp_buffer'] = true

vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/alker0/chezmoi.vim',
  'https://github.com/xvzc/chezmoi.nvim',
}, { confirm = false })

require('chezmoi').setup({})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { os.getenv('HOME') .. '/.local/share/chezmoi/*' },
  callback = function(args)
    local bufnr = args.buf

    local edit_watch = function()
      if
        vim.api.nvim_buf_is_valid(bufnr)
        and vim.api.nvim_buf_is_loaded(bufnr)
        and vim.bo[bufnr].buftype == ''
        and vim.api.nvim_buf_get_name(bufnr) ~= ''
      then
        require('chezmoi.commands.__edit').watch(bufnr)
      end
    end

    vim.schedule(edit_watch)
  end,
})
