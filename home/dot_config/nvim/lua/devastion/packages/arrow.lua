require("devastion.utils.pkg").add({
  {
    src = "otavioschwanck/arrow.nvim",
    data = {
      disabled = true,
      event = { "BufReadPost", "BufWritePost", "BufNewFile" },
      config = function()
        require("arrow").setup({
          show_icons = true,
          always_show_path = true,
          separate_by_branch = false,
          leader_key = "m",
          buffer_leader_key = "M",
          separate_save_and_remove = true,
          per_buffer_config = {
            sort_automatically = false,
          },
          mappings = {
            edit = "e",
            delete_mode = "x",
            clear_all_items = "C",
            toggle = "s",
            open_vertical = "v",
            open_horizontal = "-",
            quit = "q",
            remove = "d",
            next_item = "]",
            prev_item = "[",
          },
        })
      end,
    },
  },
})
