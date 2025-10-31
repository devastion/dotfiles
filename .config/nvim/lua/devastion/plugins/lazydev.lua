---@type LazySpec
return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      "lazy.nvim",
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
  config = function(_, opts)
    local lazydev = require("lazydev")
    lazydev.setup(opts)

    local function root_dir(bufnr, on_dir)
      -- attach to existing workspace if possible
      local ws = lazydev.find_workspace(bufnr)
      if ws ~= nil then
        return on_dir(ws)
      end

      -- use ~/.config/nvim for everything nvim-related as that seems to work best
      local buf_name = vim.api.nvim_buf_get_name(bufnr)
      if
        vim.fs.relpath(vim.fn.stdpath("config"), buf_name)
        or vim.fs.relpath(vim.fn.stdpath("data"), buf_name)
        or vim.fs.relpath(vim.env.VIMRUNTIME, buf_name)
      then
        return on_dir(vim.fn.stdpath("config"))
      end

      -- fallback to default (luarc, git, …)
      return on_dir(nil)
    end

    vim.lsp.config("lua_ls", {
      root_dir = root_dir,
    })

    vim.schedule(function()
      vim.lsp.config("lua_ls", { root_dir = root_dir })
    end)
  end,
}
