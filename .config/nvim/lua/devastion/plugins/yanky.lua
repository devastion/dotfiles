---@type LazySpec
return {
  "gbprod/yanky.nvim",
  lazy = true,
  opts = {
    ring = {
      history_length = 1000,
    },
    highlight = {
      on_yank = false,
      on_put = false,
      timer = 150,
    },
    textobj = { enabled = true },
  },
  keys = {
    {
      "<leader>p",
      ---@diagnostic disable-next-line: undefined-field
      function() Snacks.picker.yanky() end,
      mode = { "n", "x" },
      desc = "Open Yank History",
    },
    {
      "y",
      function() return require("yanky").yank() end,
      mode = { "n", "x" },
      desc = "Yank Text",
      expr = true,
    },
    {
      "p",
      function() require("yanky").put("p") end,
      mode = { "n", "x" },
      desc = "Put Text After Cursor",
    },
    {
      "P",
      function() require("yanky").put("P") end,
      mode = { "n", "x" },
      desc = "Put Text Before Cursor",
    },
    {
      "gp",
      function() require("yanky").put("gp") end,
      mode = { "n", "x" },
      desc = "Put Text After Selection",
    },
    {
      "gP",
      function() require("yanky").put("gP") end,
      mode = { "n", "x" },
      desc = "Put Text Before Selection",
    },
    {
      "[y",
      function() require("yanky").cycle(1) end,
      desc = "Cycle Forward Through Yank History",
    },
    {
      "]y",
      function() require("yanky").cycle(-1) end,
      desc = "Cycle Backward Through Yank History",
    },
    {
      "]p",
      function() require("yanky").put("]p") end,
      desc = "Put Indented After Cursor (Linewise)",
    },
    {
      "[p",
      function() require("yanky").put("[p") end,
      desc = "Put Indented Before Cursor (Linewise)",
    },
    {
      "]P",
      function() require("yanky").put("]P") end,
      desc = "Put Indented After Cursor (Linewise)",
    },
    {
      "[P",
      function() require("yanky").put("[P") end,
      desc = "Put Indented Before Cursor (Linewise)",
    },
    {
      ">p",
      function()
        require("yanky").put("]p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change(">>")))
      end,
      desc = "Put and Indent Right",
    },
    {
      "<p",
      function()
        require("yanky").put("]p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change("<<")))
      end,
      desc = "Put and Indent Left",
    },
    {
      "=p",
      function()
        require("yanky").put("p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change("==")))
      end,
      desc = "Put After Applying a Filter",
    },
    {
      ">P",
      function()
        require("yanky").put("[p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change(">>")))
      end,
      desc = "Put Before and Indent Right",
    },
    {
      "<P",
      function()
        require("yanky").put("[p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change("<<")))
      end,
      desc = "Put Before and Indent Left",
    },
    {
      "=P",
      function()
        require("yanky").put("P", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change("==")))
      end,
      desc = "Put Before Applying a Filter",
    },
    {
      "iy",
      function() require("yanky.textobj").last_put() end,
      mode = { "o", "x" },
    },
  },
}
