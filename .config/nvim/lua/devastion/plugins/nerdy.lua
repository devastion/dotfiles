---@type LazySpec
return {
  "2kabhishek/nerdy.nvim",
  cmd = "Nerdy",
  opts = {
    max_recents = 30,
    add_default_keybindings = false,
    copy_to_clipboard = true,
    copy_register = "+",
  },
  keys = {
    {
      "<leader>fN",
      function()
        vim.cmd("Nerdy list")
      end,
      desc = "Nerd Font Glyphs",
    },
  },
}
