---@type LazySpec
return {
  "stackinthewild/headhunter.nvim",
  opts = {
    enabled = true,
    keys = false,
  },
  keys = function()
    return {
      {
        "<leader>gx",
        "",
        desc = "+[Conflicts]",
      },
      {
        "]x",
        function()
          require("headhunter").next_conflict()
        end,
        desc = "Go to next Git conflict",
      },
      {
        "[x",
        function()
          require("headhunter").prev_conflict()
        end,
        desc = "Go to previous Git conflict",
      },
      {
        "<leader>gxh",
        function()
          require("headhunter").take_head()
        end,
        desc = "Take changes from HEAD",
      },
      {
        "<leader>gxo",
        function()
          require("headhunter").take_origin()
        end,
        desc = "Take changes from origin",
      },
      {
        "<leader>gxb",
        function()
          require("headhunter").take_both()
        end,
        desc = "Take both changes",
      },
      {
        "<leader>gxq",
        function()
          require("headhunter").populate_quickfix()
        end,
        desc = "List Git conflicts in quickfix",
      },
    }
  end,
}
