---@type LazySpec
return {
  "vuki656/package-info.nvim",
  event = { "BufReadPost package.json" },
  opts = {},
  keys = function()
    require("which-key").add({ "<leader>n", group = "+[Package Info]" })
    return {
      {
        "<leader>ns",
        function()
          require("package-info").show()
        end,
        mode = "n",
        desc = "Show Package Info",
        ft = "json",
      },
      {
        "<leader>nh",
        function()
          require("package-info").hide()
        end,
        mode = "n",
        desc = "Hide Package Info",
        ft = "json",
      },
      {
        "<leader>nt",
        function()
          require("package-info").toggle()
        end,
        mode = "n",
        desc = "Toggle Package Info",
        ft = "json",
      },
      {
        "<leader>nu",
        function()
          require("package-info").update()
        end,
        mode = "n",
        desc = "Update Package",
        ft = "json",
      },
      {
        "<leader>nd",
        function()
          require("package-info").delete()
        end,
        mode = "n",
        desc = "Delete Package",
        ft = "json",
      },
      {
        "<leader>ni",
        function()
          require("package-info").install()
        end,
        mode = "n",
        desc = "Install Package",
        ft = "json",
      },
      {
        "<leader>nc",
        function()
          require("package-info").change_version()
        end,
        mode = "n",
        desc = "Change Package Version",
        ft = "json",
      },
    }
  end,
}
