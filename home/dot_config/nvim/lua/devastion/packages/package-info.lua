local map = require("devastion.utils").map
local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup

require("devastion.utils.pkg").add({
  {
    src = "vuki656/package-info.nvim",
    data = {
      event = { "BufReadPost" },
      pattern = "package.json",
      config = function()
        require("package-info").setup()
        require("which-key").add({
          { "<localleader>p", group = "+[Package Info]", mode = { "n", "x" } },
        })

        autocmd("BufReadPost", {
          group = augroup("package_info"),
          pattern = "package.json",
          callback = function(event)
            local opts = { buffer = event.buf, silent = true, noremap = true }

            map("<localleader>ps", function()
              require("package-info").show()
            end, "Show Package Info", "n", opts)

            map("<localleader>ph", function()
              require("package-info").hide()
            end, "Hide Package Info", "n", opts)

            map("<localleader>pt", function()
              require("package-info").toggle()
            end, "Toggle Package Info", "n", opts)

            map("<localleader>pu", function()
              require("package-info").update()
            end, "Update Package", "n", opts)

            map("<localleader>pd", function()
              require("package-info").delete()
            end, "Delete Package", "n", opts)

            map("<localleader>pi", function()
              require("package-info").install()
            end, "Install Package", "n", opts)

            map("<localleader>pc", function()
              require("package-info").change_version()
            end, "Change Package Version", "n", opts)
          end,
        })
      end,
    },
  },
})
