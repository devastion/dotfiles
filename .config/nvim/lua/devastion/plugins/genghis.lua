---@type LazySpec
return {
  "chrisgrieser/nvim-genghis",
  lazy = true,
  cmd = {
    "Genghis",
  },
  opts = {},
  keys = {
    { "<leader>F", "", desc = "+[File Operations]" },
    {
      "<leader>Fn",
      function()
        require("genghis").createNewFile()
      end,
      desc = "New File",
    },
    {
      "<leader>FN",
      function()
        require("genghis").createNewFileInFolder()
      end,
      desc = "New File (cwd)",
    },
    {
      "<leader>Fd",
      function()
        require("genghis").duplicateFile()
      end,
      desc = "Duplicate File",
    },
    {
      "<leader>Fn",
      function()
        require("genghis").moveSelectionToNewFile()
      end,
      desc = "New File with Selection",
      mode = "x",
    },
    {
      "<leader>Fr",
      function()
        require("genghis").renameFile()
      end,
      desc = "Rename File",
    },
    {
      "<leader>Fm",
      function()
        require("genghis").moveToFolderInCwd()
      end,
      desc = "Move File to CWD",
    },
    {
      "<leader>FM",
      function()
        require("genghis").moveAndRenameFile()
      end,
      desc = "Move and Rename File to CWD",
    },
    {
      "<leader>FX",
      function()
        require("genghis").chmodx()
      end,
      desc = "Execute chmod +x on Current File",
    },
    {
      "<leader>FD",
      function()
        require("genghis").trashFile()
      end,
      desc = "Trash File",
    },
    {
      "<leader>Fo",
      function()
        require("genghis").showInSystemExplorer()
      end,
      desc = "Show in System Explorer",
    },
    { "<leader>Fc", "", desc = "+[Copy]" },
    {
      "<leader>Fcn",
      function()
        require("genghis").copyFilename()
      end,
      desc = "File Name",
    },
    {
      "<leader>Fcp",
      function()
        require("genghis").copyFilepath()
      end,
      desc = "File Path",
    },
    {
      "<leader>FcP",
      function()
        require("genghis").copyFilepathWithTilde()
      end,
      desc = "Absolute Path with Tilde",
    },
    {
      "<leader>Fcr",
      function()
        require("genghis").copyRelativePath()
      end,
      desc = "Relative Path",
    },
    {
      "<leader>Fcd",
      function()
        require("genghis").copyDirectoryPath()
      end,
      desc = "Directory Path",
    },
    {
      "<leader>FcD",
      function()
        require("genghis").copyRelativeDirectoryPath()
      end,
      desc = "Relative Directory Path",
    },
    {
      "<leader>Fcf",
      function()
        require("genghis").copyFileItself()
      end,
      desc = "Copy the File Itself",
    },
  },
}
