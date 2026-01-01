---@type LazySpec
return {
  "mistricky/codesnap.nvim",
  tag = "v2.0.0-beta.17",
  cmd = {
    "CodeSnap",
    "CodeSnapSave",
    "CodeSnapHighlight",
    "CodeSnapSaveHighlight",
    "CodeSnapASCII",
  },
  opts = {
    show_line_number = true,
    highlight_color = "#ffffff20",
    show_workspace = true,
    snapshot_config = {
      theme = "candy",
      window = {
        mac_window_bar = false,
        shadow = {
          radius = 20,
          color = "#00000040",
        },
        margin = {
          x = 0,
          y = 0,
        },
        border = {
          width = 1,
          color = "#ffffff30",
        },
        title_config = {
          color = "#ffffff",
          font_family = "Pacifico",
        },
      },
      themes_folders = {},
      fonts_folders = {},
      line_number_color = "#495162",
      command_output_config = {
        prompt = "❯",
        font_family = "Maple Mono Normal NF",
        prompt_color = "#F78FB3",
        command_color = "#98C379",
        string_arg_color = "#ff0000",
      },
      code_config = {
        font_family = "Maple Mono Normal NF",
        breadcrumbs = {
          enable = true,
          separator = "/",
          color = "#80848b",
          font_family = "Maple Mono Normal NF",
        },
      },
      watermark = {
        content = "",
        font_family = "Maple Mono Normal NF",
        color = "#ffffff",
      },
      background = {
        start = {
          x = 0,
          y = 0,
        },
        ["end"] = {
          x = "max",
          y = 0,
        },
        stops = {
          {
            position = 0,
            color = "#6bcba5",
          },
          {
            position = 1,
            color = "#caf4c2",
          },
        },
      },
    },
  },
  keys = {
    {
      "<c-s>",
      ":CodeSnap<cr>",
      desc = "Codesnap Save Snapshot to Clipboard",
      mode = { "x" },
      silent = true,
    },
    {
      "<leader><c-s>",
      function()
        local filename = vim.fn.expand("%:t")
        local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
        local codesnap_filepath = vim.env.HOME .. "/Pictures/codesnap/" .. filename .. "_" .. timestamp .. ".png"

        return ":CodeSnapSave " .. codesnap_filepath .. "<cr>"
      end,
      desc = "Codesnap Save Snapshot",
      mode = { "x" },
      silent = true,
      expr = true,
    },
  },
}
