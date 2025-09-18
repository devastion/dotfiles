vim.pack.add({ "https://github.com/otavioschwanck/arrow.nvim" }, { confirm = false })

require("arrow").setup({
  show_icons = true,
  leader_key = "m",
  buffer_leader_key = "M",
  separate_by_branch = true,
  separate_save_and_remove = true,
  per_buffer_config = {
    sort_automatically = false,
  },
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
