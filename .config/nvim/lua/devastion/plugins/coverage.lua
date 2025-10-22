---@type LazySpec
return {
  "andythigpen/nvim-coverage",
  version = "*",
  ft = { "php", "typescript", "python" },
  dependencies = { "asb/lua-xmlreader" },
  opts = {
    auto_reload = true,
    highlights = {
      covered = { fg = "#449dab" },
      uncovered = { fg = "#914c54" },
    },
  },
  config = function(_, opts)
    require("coverage").setup(opts)
  end,
  keys = {
    {
      "<leader>tc",
      function()
        require("coverage").load(true)
      end,
      desc = "Load Coverage",
      ft = { "php", "typescript", "python" },
    },
    {
      "<leader>uC",
      function()
        require("coverage").toggle()
      end,
      desc = "Toggle Coverage",
      ft = { "php", "typescript", "python" },
    },
  },
}
