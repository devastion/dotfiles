local map = require("devastion.utils").remap

map("<leader>fc", function()
  require("fzf-lua").files({
    cmd = "fd -g -p -t f '**/controllers/**'",
  })
end, "Controllers", "n", { buffer = true })
map("<leader>fm", function()
  require("fzf-lua").files({
    cmd = "fd -g -p -t f '**/models/**'",
  })
end, "Models", "n", { buffer = true })
map("<leader>fs", function()
  require("fzf-lua").files({
    cmd = "fd -g -p -t f '**/services/**' --exclude='tests'",
  })
end, "Services", "n", { buffer = true })
map("<leader>ft", function()
  require("fzf-lua").files({
    cmd = "fd -g -p -t f '**/tests/**'",
  })
end, "Tests", "n", { buffer = true })
