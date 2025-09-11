MiniDeps.later(function()
  MiniDeps.add({
    source = "gbprod/yanky.nvim",
    depends = { "kkharji/sqlite.lua" },
  })

  local map = function(lhs, rhs, desc, mode, opts)
    opts = opts or {}
    opts.desc = desc
    mode = mode or "n"
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  require("yanky").setup({
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
  })

  map("<leader>p", function() require("yanky.picker").select_in_history() end, "Open Yank History", { "n", "x" })
  map("y", function() return require("yanky").yank() end, "Yank Text", { "n", "x" }, { expr = true })
  map("p", function() require("yanky").put("p") end, "Put Text After Cursor", { "n", "x" })
  map("P", function() require("yanky").put("P") end, "Put Text Before Cursor", { "n", "x" })
  map("gp", function() require("yanky").put("gp") end, "Put Text After Selection", { "n", "x" })
  map("gP", function() require("yanky").put("gP") end, "Put Text Before Selection", { "n", "x" })
  map("[y", function() require("yanky").cycle(1) end, "Cycle Forward Through Yank History")
  map("]y", function() require("yanky").cycle(-1) end, "Cycle Backward Through Yank History")
  -- map("]p", function() require("yanky").put("]p") end, "Put Indented After Cursor (Linewise)")
  -- map("[p", function() require("yanky").put("[p") end, "Put Indented Before Cursor (Linewise)")
  -- map("]P", function() require("yanky").put("]P") end, "Put Indented After Cursor (Linewise)")
  -- map("[P", function() require("yanky").put("[P") end, "Put Indented Before Cursor (Linewise)")
  map(
    ">p",
    function()
      require("yanky").put("]p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change(">>")))
    end,
    "Put and Indent Right"
  )
  map(
    "<p",
    function()
      require("yanky").put("]p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change("<<")))
    end,
    "Put and Indent Left"
  )
  map(
    "=p",
    function()
      require("yanky").put("p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change("==")))
    end,
    "Put After Applying a Filter"
  )
  map(
    ">P",
    function()
      require("yanky").put("[p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change(">>")))
    end,
    "Put Before and Indent Right"
  )
  map(
    "<P",
    function()
      require("yanky").put("[p", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change("<<")))
    end,
    "Put Before and Indent Left"
  )
  map(
    "=P",
    function()
      require("yanky").put("P", false, require("yanky.wrappers").linewise(require("yanky.wrappers").change("==")))
    end,
    "Put Before Applying a Filter"
  )
  map("iy", function() require("yanky.textobj").last_put() end, nil, { "o", "x" })
end)
