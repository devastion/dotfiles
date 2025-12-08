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
    { "<leader>fC", "", desc = "+[Copy]" },
    {
      "<leader>fCn",
      function()
        require("genghis").copyFilename()
      end,
      desc = "File Name",
    },
    {
      "<leader>fCp",
      function()
        require("genghis").copyFilepath()
      end,
      desc = "File Path",
    },
    {
      "<leader>fCP",
      function()
        require("genghis").copyFilepathWithTilde()
      end,
      desc = "Absolute Path with Tilde",
    },
    {
      "<leader>fCr",
      function()
        require("genghis").copyRelativePath()
      end,
      desc = "Relative Path",
    },
    {
      "<leader>fCd",
      function()
        require("genghis").copyDirectoryPath()
      end,
      desc = "Directory Path",
    },
    {
      "<leader>fCD",
      function()
        require("genghis").copyRelativeDirectoryPath()
      end,
      desc = "Relative Directory Path",
    },
    {
      "<leader>fCf",
      function()
        require("genghis").copyFileItself()
      end,
      desc = "Copy the File Itself",
    },
  },
}
