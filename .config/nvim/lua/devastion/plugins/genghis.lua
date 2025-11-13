---@type LazySpec
return {
  "chrisgrieser/nvim-genghis",
  lazy = true,
  cmd = {
    "Genghis",
  },
  opts = {},
  keys = {
    {
      "<leader>fn",
      function()
        require("genghis").createNewFile()
      end,
      desc = "New File",
    },
    {
      "<leader>fn",
      function()
        require("genghis").moveSelectionToNewFile()
      end,
      desc = "New File with Selection",
      mode = "x",
    },
    {
      "<leader>fd",
      function()
        require("genghis").trashFile()
      end,
      desc = "Trash File",
    },
  },
}
