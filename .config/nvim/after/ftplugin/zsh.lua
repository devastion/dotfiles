vim.g.remap("<leader>cL", function()
  require("lint").try_lint("shellcheck_bash")
end, "Shellcheck (--shell=bash)")
