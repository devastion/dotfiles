---@type LazySpec
return {
  "danymat/neogen",
  cmd = "Neogen",
  keys = {
    {
      "<leader>cn",
      function()
        require("neogen").generate()
      end,
      desc = "Generate Annotations (Neogen)",
    },
  },
  opts = {
    snippet_engine = "nvim",
    languages = {
      lua = { template = { annotation_convention = "emmylua" } },
      python = { template = { annotation_convention = "numpydoc" } },
    },
  },
}
