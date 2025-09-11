MiniDeps.later(function()
  MiniDeps.add({ source = "otavioschwanck/arrow.nvim" })

  require("arrow").setup({
    show_icons = true,
    leader_key = "m",
    buffer_leader_key = "M",
    mappings = {
      edit = "e",
      delete_mode = "d",
      clear_all_items = "C",
      toggle = "s",
      open_vertical = "v",
      open_horizontal = "-",
      quit = "q",
      remove = "x",
      next_item = "]",
      prev_item = "[",
    },
  })
end)
