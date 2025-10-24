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
    cd_type = "tab",
    opener = function(dir, _, selected_path)
      vim.cmd("tabnew")
      if selected_path then
        vim.cmd("edit " .. selected_path)
      end
    end,
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
