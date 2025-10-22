---@type LazySpec
return {
  "chrisgrieser/nvim-spider",
  lazy = true,
  opts = {
    skipInsignificantPunctuation = false,
    consistentOperatorPending = true,
    subwordMovement = true,
    customPatterns = {},
  },
  keys = {
    {
      "w",
      function()
        require("spider").motion("w")
      end,
      mode = { "n", "o", "x" },
    },
    {
      "e",
      function()
        require("spider").motion("e")
      end,
      mode = { "n", "o", "x" },
    },
    {
      "b",
      function()
        require("spider").motion("b")
      end,
      mode = { "n", "o", "x" },
    },
    {
      "cw",
      "c<cmd>lua require('spider').motion('e')<cr>",
    },
    {
      "<c-f>",
      "<Esc>l<cmd>lua require('spider').motion('w')<cr>i",
      mode = "i",
    },
    {
      "<c-b>",
      "<Esc>l<cmd>lua require('spider').motion('b')<cr>i",
      mode = "i",
    },
  },
}
