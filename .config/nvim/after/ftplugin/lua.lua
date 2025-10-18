vim.b.autoformat_enabled = true

local map = require("devastion.utils").remap

map("<leader>fp", function()
  require("fzf-lua").files({
    cmd = "fd -g -p -t f '**/plugins/*'",
  })
end, "Plugins", "n", { buffer = true })
map("<leader>fl", function()
  require("fzf-lua").files({
    cmd = "fd -g -p -t f '**/lsp/*'",
  })
end, "LSP", "n", { buffer = true })
map("<leader>ft", function()
  require("fzf-lua").files({
    cmd = "fd -g -p -t f '**/ftplugin/**'",
  })
end, "FTPlugin", "n", { buffer = true })
map("<leader>fc", function()
  require("fzf-lua").files({
    cmd = "fd -g -p -t f '**/core/**'",
  })
end, "Core", "n", { buffer = true })
