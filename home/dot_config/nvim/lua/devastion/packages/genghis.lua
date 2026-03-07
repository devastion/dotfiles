local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "chrisgrieser/nvim-genghis",
    data = {
      config = function()
        require("which-key").add({
          { "<leader>F", group = "+[File Operations]", mode = { "n", "x" } },
          { "<leader>Fc", group = "+[Copy]", mode = { "n", "x" } },
        })

        map("<leader>Fn", function()
          require("genghis").createNewFile()
        end, "New File")

        map("<leader>FN", function()
          require("genghis").createNewFileInFolder()
        end, "New File (cwd)")

        map("<leader>Fd", function()
          require("genghis").duplicateFile()
        end, "Duplicate File")

        map("<leader>Fn", function()
          require("genghis").moveSelectionToNewFile()
        end, "New File with Selection", "x")

        map("<leader>Fr", function()
          require("genghis").renameFile()
        end, "Rename File")

        map("<leader>Fm", function()
          require("genghis").moveToFolderInCwd()
        end, "Move File to CWD")

        map("<leader>FM", function()
          require("genghis").moveAndRenameFile()
        end, "Move and Rename File to CWD")

        map("<leader>FX", function()
          require("genghis").chmodx()
        end, "Execute chmod +x on Current File")

        map("<leader>FD", function()
          require("genghis").trashFile()
        end, "Trash File")

        map("<leader>Fo", function()
          require("genghis").showInSystemExplorer()
        end, "Show in System Explorer")

        map("<leader>Fcn", function()
          require("genghis").copyFilename()
        end, "File Name")

        map("<leader>Fcp", function()
          require("genghis").copyFilepath()
        end, "File Path")

        map("<leader>FcP", function()
          require("genghis").copyFilepathWithTilde()
        end, "Absolute Path with Tilde")

        map("<leader>Fcr", function()
          require("genghis").copyRelativePath()
        end, "Relative Path")

        map("<leader>Fcd", function()
          require("genghis").copyDirectoryPath()
        end, "Directory Path")

        map("<leader>FcD", function()
          require("genghis").copyRelativeDirectoryPath()
        end, "Relative Directory Path")

        map("<leader>Fcf", function()
          require("genghis").copyFileItself()
        end, "Copy the File Itself")
      end,
    },
  },
})
