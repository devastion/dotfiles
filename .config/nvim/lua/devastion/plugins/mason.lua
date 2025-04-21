---@type LazySpec
return {
  "williamboman/mason.nvim",
  cmd = { "Mason", "MasonUpdate" },
  build = ":MasonUpdate",
  keys = {
    {
      "<leader>cm",
      function() require("mason.api.command").Mason() end,
      desc = "Mason",
    },
  },
  opts_extend = { "ensure_installed" },
  opts = {
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
      border = "single",
      width = 0.8,
      height = 0.8,
    },
    ensure_installed = {},
  },
  config = function(_, opts)
    local common_utils = require("devastion.utils.common")
    local lsp_utils = require("devastion.utils.lsp")
    local lsp_configs = lsp_utils.lsp_configs()
    if type(opts.ensure_installed) == "table" then
      -- Add all lsp servers
      for _, v in ipairs(lsp_configs) do
        table.insert(opts.ensure_installed, v)
      end

      opts.ensure_installed = common_utils.dedup(opts.ensure_installed)
    end
    require("mason").setup(opts)

    require("mason-registry"):on("package:install:success", function()
      vim.defer_fn(
        function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end,
        100
      )
    end)

    lsp_utils.mason_install(opts.ensure_installed)
  end,
  init = function() vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, "/") .. ":" .. vim.env.PATH end,
}
