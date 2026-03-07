require("devastion.utils.pkg").add({
  {
    src = "nvim-mini/mini.move",
    data = {
      config = function()
        require("mini.move").setup()
      end,
    },
  },
})
