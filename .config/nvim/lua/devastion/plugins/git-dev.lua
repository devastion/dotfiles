---@type LazySpec
return {
  "moyiz/git-dev.nvim",
  lazy = true,
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  cmd = {
    "GitDevClean",
    "GitDevCleanAll",
    "GitDevCloseBuffers",
    "GitDevOpen",
    "GitDevRecents",
    "GitDevToggleUI",
    "GitDevXDGHandle",
  },
  opts = {
    ephemeral = false,
  },
  keys = {
    {
      "<leader>gO",
      function()
        local repo = vim.fn.input("Repository name / URI: ")
        if repo ~= "" then
          require("git-dev").open(repo)
        end
      end,
      desc = "[O]pen a remote git repository",
    },
  },
}
