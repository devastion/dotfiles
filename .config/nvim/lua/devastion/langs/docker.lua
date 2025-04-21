---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "dockerfile-language-server",
        "docker-compose-language-service",
        -- "hadolint",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts) opts.formatters_by_ft["dockerfile"] = opts.formatters_by_ft["dockerfile"] or {} end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        dockerfile = { "hadolint" },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "dockerfile",
      },
    },
  },
}
