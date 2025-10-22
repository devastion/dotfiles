---@type LazySpec
return {
  "magicduck/grug-far.nvim",
  opts = { headerMaxWidth = 80 },
  cmd = { "GrugFar", "GrugFarWithin" },
  keys = {
    {
      "<leader>cR",
      function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
      end,
      mode = { "n", "v" },
      desc = "Search and Replace",
    },
  },
}
