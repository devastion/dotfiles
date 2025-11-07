---@type LazySpec
return {
  "romus204/referencer.nvim",
  cmd = {
    "ReferencerToggle",
    "ReferencerUpdate",
  },
  opts = {
    format = "%d ref(s)",
  },
  keys = {
    {
      "<leader>ur",
      function()
        require("referencer").toggle()
      end,
      desc = "Toggle Referencer",
    },
  },
}
