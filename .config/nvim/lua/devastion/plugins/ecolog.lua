---@type LazySpec
return {
  "ph1losof/ecolog.nvim",
  lazy = false,
  opts = {
    vim_env = true,
    integrations = {
      blink_cmp = true,
      lsp = true,
      fzf = {
        shelter = {
          mask_on_copy = false,
        },
        mappings = {
          copy_value = "ctrl-y",
          copy_name = "ctrl-Y",
          append_value = "ctrl-a",
          append_name = "enter",
          edit_var = "ctrl-e",
        },
      },
      statusline = {
        hidden_mode = true,
      },
    },
    shelter = {
      configuration = {
        partial_mode = {
          show_start = 3,
          show_end = 3,
          min_mask = 3,
        },
        mask_char = "*",
        mask_length = nil,
        skip_comments = false,
      },
      modules = {
        cmp = true,
        peek = false,
        files = true,
        telescope = false,
        telescope_previewer = false,
        fzf = true,
        fzf_previewer = true,
        snacks_previewer = false,
        snacks = false,
      },
    },
    types = true,
    path = vim.fn.getcwd(),
    preferred_environment = "development",
    provider_patterns = true,
  },
}
