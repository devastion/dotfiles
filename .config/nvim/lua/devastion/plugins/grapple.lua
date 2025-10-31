---@type LazySpec
return {
  "cbochs/grapple.nvim",
  opts = {
    scope = "git_branch",
  },
  event = { "BufReadPost", "BufNewFile" },
  cmd = "Grapple",
  keys = {
    {
      ";",
      function()
        require("grapple").toggle_tags()
      end,
      desc = "Toggle tags menu",
    },
    {
      "<c-s>",
      function()
        require("grapple").tag()
      end,
      desc = "Tag",
    },
    {
      "<c-s-s>",
      function()
        require("grapple").untag()
      end,
      desc = "Untag",
    },
  },
}
