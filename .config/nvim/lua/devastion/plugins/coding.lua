---@type LazySpec
return {
  {
    "gbprod/yanky.nvim",
    dependencies = { "kkharji/sqlite.lua" },
    opts = {
      ring = {
        storage = "sqlite",
        storage_path = vim.fn.stdpath("data") .. "/databases/yanky.db",
        history_length = 10000,
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
        function()
          require("yanky.picker").select_in_history()
        end,
        mode = { "n", "x" },
        desc = "Open Yank History",
      },
      {
        "y",
        function()
          return require("yanky").yank()
        end,
        mode = { "n", "x" },
        desc = "Yank Text",
        expr = true,
        noremap = false,
      },
      {
        "p",
        function()
          require("yanky").put("p")
        end,
        mode = { "n", "x" },
        desc = "Put Text After Cursor",
      },
      {
        "P",
        function()
          require("yanky").put("P")
        end,
        mode = { "n", "x" },
        desc = "Put Text Before Cursor",
      },
      {
        "gp",
        function()
          require("yanky").put("gp")
        end,
        mode = { "n", "x" },
        desc = "Put Text After Selection",
      },
      {
        "gP",
        function()
          require("yanky").put("gP")
        end,
        mode = { "n", "x" },
        desc = "Put Text Before Selection",
      },
      {
        "[y",
        function()
          require("yanky").cycle(1)
        end,
        mode = "n",
        desc = "Cycle Forward Through Yank History",
      },
      {
        "]y",
        function()
          require("yanky").cycle(-1)
        end,
        mode = "n",
        desc = "Cycle Backward Through Yank History",
      },
      {
        ">p",
        function()
          require("yanky").put("]p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change(">>")))
        end,
        mode = "n",
        desc = "Put and Indent Right",
      },
      {
        "<p",
        function()
          require("yanky").put("]p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change("<<")))
        end,
        mode = "n",
        desc = "Put and Indent Left",
      },
      {
        "=p",
        function()
          require("yanky").put("p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change("==")))
        end,
        mode = "n",
        desc = "Put After Applying a Filter",
      },
      {
        ">P",
        function()
          require("yanky").put("[p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change(">>")))
        end,
        mode = "n",
        desc = "Put Before and Indent Right",
      },
      {
        "<P",
        function()
          require("yanky").put("[p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change("<<")))
        end,
        mode = "n",
        desc = "Put Before and Indent Left",
      },
      {
        "=P",
        function()
          require("yanky").put("P", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change("==")))
        end,
        mode = "n",
        desc = "Put Before Applying a Filter",
      },
      {
        "iy",
        function()
          require("yanky.textobj").last_put()
        end,
        mode = { "o", "x" },
      },
    },
  },
  {
    "danymat/neogen",
    cmd = "Neogen",
    keys = {
      {
        "<leader>cn",
        function()
          require("neogen").generate()
        end,
        desc = "Generate Annotations (Neogen)",
      },
    },
    opts = {
      snippet_engine = "nvim",
      languages = {
        lua = { template = { annotation_convention = "emmylua" } },
        python = { template = { annotation_convention = "numpydoc" } },
      },
    },
  },
}
