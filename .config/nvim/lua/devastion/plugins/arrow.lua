---@type LazySpec
return {
  "otavioschwanck/arrow.nvim",
  keys = {
    {
      "m",
      function()
        require("arrow.commands").commands.open()
      end,
      desc = "Arrow File Mappings",
    },
    {
      "M",
      function()
        require("arrow.commands").commands.open(vim.api.nvim_get_current_buf())
      end,
      desc = "Arrow Buffer Mappings",
    },
  },
  opts = {
    show_icons = true,
    always_show_path = true,
    separate_by_branch = true,
    leader_key = "m",
    buffer_leader_key = "M",
    separate_save_and_remove = true,
    per_buffer_config = {
      sort_automatically = false,
    },
  },
}
