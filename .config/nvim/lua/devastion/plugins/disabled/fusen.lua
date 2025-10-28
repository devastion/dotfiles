---@type LazySpec
return {
  "walkersumida/fusen.nvim",
  -- INFO: Terrible performance
  enabled = false,
  event = { "VeryLazy" },
  opts = {},
  keys = {
    { "m", "", desc = "+[Fusen]" },
    {
      "me",
      function()
        require("fusen").add_mark()
      end,
      desc = "Add Mark",
    },
    {
      "mc",
      function()
        require("fusen").clear_mark()
      end,
      desc = "Clear Current Line",
    },
    {
      "mC",
      function()
        require("fusen").clear_buffer()
      end,
      desc = "Clear Buffer",
    },
    {
      "mD",
      function()
        require("fusen").clear_all()
      end,
      desc = "Clear All",
    },
    {
      "mn",
      function()
        require("fusen").next_mark()
      end,
      desc = "Next Mark",
    },
    {
      "mp",
      function()
        require("fusen").prev_mark()
      end,
      desc = "Prev Mark",
    },
    {
      "ml",
      function()
        require("fusen").list_marks()
      end,
      desc = "List Marks",
    },
  },
}
