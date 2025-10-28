---@type LazySpec
return {
  "nvim-focus/focus.nvim",
  version = "*",
  event = { "VeryLazy" },
  opts = {
    ui = {
      signcolumn = false,
    },
  },
  init = function()
    local ignore_filetypes = {
      "qf",
      "dapui_scopes",
      "dapui_stacks",
      "dapui_repl",
      "dapui_watches",
      "dapui_breakpoints",
      "dapui_console",
    }

    local augroup = vim.api.nvim_create_augroup("FocusDisable", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      callback = function(_)
        if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
          vim.b.focus_disable = true
        else
          vim.b.focus_disable = false
        end
      end,
      desc = "Disable focus autoresize for FileType",
    })
  end,
}
