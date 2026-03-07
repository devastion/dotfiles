require("devastion.utils.pkg").add({
  {
    src = "johmsalas/text-case.nvim",
    data = {
      config = function()
        require("textcase").setup({ prefix = "<localleader>c" })
      end,
    },
  },
})
