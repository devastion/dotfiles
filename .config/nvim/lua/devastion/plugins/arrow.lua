---@type LazySpec
return {
  "otavioschwanck/arrow.nvim",
  event = "VeryLazy",
  dependencies = {
    "echasnovski/mini.icons",
  },
  opts = {
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
  },
}
