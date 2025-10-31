---@type LazySpec
return {
  "mistricky/codesnap.nvim",
  build = "make build_generator",
  cmd = {
    "CodeSnap",
    "CodeSnapSave",
    "CodeSnapHighlight",
    "CodeSnapSaveHighlight",
    "CodeSnapASCII",
  },
  opts = {
    mac_window_bar = true,
    title = "",
    code_font_family = "Maple Mono Normal NF",
    watermark_font_family = "Maple Mono Normal NF",
    watermark = "",
    bg_theme = "default",
    breadcrumbs_separator = "/",
    has_breadcrumbs = true,
    has_line_number = true,
    show_workspace = true,
    min_width = 0,
    bg_x_padding = 122,
    bg_y_padding = 82,
    save_path = "~/Pictures/codesnap",
  },
  keys = {
    {
      "<c-s>",
      "<cmd>CodeSnapSave<cr>",
      desc = "Codesnap Save Snapshot",
      mode = { "x" },
    },
  },
}
