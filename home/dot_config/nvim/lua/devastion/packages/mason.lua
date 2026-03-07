local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "mason-org/mason.nvim",
    data = {
      init = function()
        vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, "/") .. ":" .. vim.env.PATH
      end,
      task = function()
        vim.schedule(function()
          vim.notify("Updating mason registries...", vim.log.levels.INFO)
          require("mason.api.command").MasonUpdate()
          vim.notify("Mason registries updated!", vim.log.levels.INFO)
        end)
      end,
      config = function()
        require("mason").setup({
          ui = {
            check_outdated_packages_on_open = true,
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗",
            },
            border = vim.g.border_style,
            width = 0.8,
            height = 0.8,
          },
        })

        map("<leader>cm", function()
          require("mason.api.command").Mason()
        end, "Mason")
      end,
    },
  },
})
