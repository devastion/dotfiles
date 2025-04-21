---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "vtsls",
        "eslint-lsp",
        "vue-language-server",
        "astro-language-server",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "javascript",
        "jsdoc",
        "typescript",
        "tsx",
        "vue",
      },
    },
  },
  {
    "dmmulroy/tsc.nvim",
    cond = function() return require("devastion.utils.lsp").is_typescript() end,
    cmd = "TSC",
    opts = {},
    keys = {
      { "<leader>cT", function() require("tsc").run() end, desc = "Typescript Typecheck" },
    },
  },
}
