require("devastion.utils.pkg").add({
  {
    src = "nvim-mini/mini.operators",
    data = {
      config = function()
        local operators = require("mini.operators")
        operators.setup({
          evaluate = {
            prefix = "",
            func = nil,
          },
          exchange = {
            prefix = "sx",
            reindent_linewise = true,
          },
          multiply = {
            prefix = "",
            func = nil,
          },
          replace = {
            prefix = "ss",
            reindent_linewise = true,
          },
          sort = {
            prefix = "so",
            func = nil,
          },
        })
        operators.make_mappings("replace", { textobject = "ss", line = "sS", selection = "ss" })
        operators.make_mappings("sort", { textobject = "so", line = "sO", selection = "so" })
      end,
    },
  },
})
