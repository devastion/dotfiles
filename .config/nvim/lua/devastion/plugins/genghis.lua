---@type LazySpec
return {
  "chrisgrieser/nvim-genghis",
  lazy = true,
  cmd = {
    "Genghis",
  },
  opts = {},
  keys = {
    { "<leader>o", "", desc = "+[File Operations]" },
    {
      "<leader>on",
      function()
        require("genghis").createNewFile()
      end,
      desc = "New File",
    },
    {
      "<leader>oN",
      function()
        require("genghis").createNewFileInFolder()
      end,
      desc = "New File (cwd)",
    },
    {
      "<leader>od",
      function()
        require("genghis").duplicateFile()
      end,
      desc = "Duplicate File",
    },
    {
      "<leader>on",
      function()
        require("genghis").moveSelectionToNewFile()
      end,
      desc = "New File with Selection",
      mode = "x",
    },
    {
      "<leader>or",
      function()
        require("genghis").renameFile()
      end,
      desc = "Rename File",
    },
    {
      "<leader>om",
      function()
        require("genghis").moveToFolderInCwd()
      end,
      desc = "Move File to CWD",
    },
    {
      "<leader>oM",
      function()
        require("genghis").moveAndRenameFile()
      end,
      desc = "Move and Rename File to CWD",
    },
    {
      "<leader>oX",
      function()
        require("genghis").chmodx()
      end,
      desc = "Execute chmod +x on Current File",
    },
    {
      "<leader>oD",
      function()
        require("genghis").trashFile()
      end,
      desc = "Trash File",
    },
    {
      "<leader>oo",
      function()
        require("genghis").showInSystemExplorer()
      end,
      desc = "Show in System Explorer",
    },
    { "<leader>oc", "", desc = "+[Copy]" },
    {
      "<leader>ocn",
      function()
        require("genghis").copyFilename()
      end,
      desc = "File Name",
    },
    {
      "<leader>ocp",
      function()
        require("genghis").copyFilepath()
      end,
      desc = "File Path",
    },
    {
      "<leader>ocP",
      function()
        require("genghis").copyFilepathWithTilde()
      end,
      desc = "Absolute Path with Tilde",
    },
    {
      "<leader>ocr",
      function()
        require("genghis").copyRelativePath()
      end,
      desc = "Relative Path",
    },
    {
      "<leader>ocd",
      function()
        require("genghis").copyDirectoryPath()
      end,
      desc = "Directory Path",
    },
    {
      "<leader>ocD",
      function()
        require("genghis").copyRelativeDirectoryPath()
      end,
      desc = "Relative Directory Path",
    },
    {
      "<leader>ocf",
      function()
        require("genghis").copyFileItself()
      end,
      desc = "Copy the File Itself",
    },
  },
}
