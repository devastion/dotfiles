vim.pack.add({ "https://github.com/mistweaverco/kulala.nvim" }, { confirm = false })

vim.g.ts_install({ "http", "graphql" })

require("kulala").setup()

local prefix = "<leader>R"

require("which-key").add({ prefix, group = "+[Rest]", mode = { "n", "v" } })

local map = require("devastion.utils").map(prefix)

map("r", function() require("kulala").run() end, "Run", { "n", "v" })
map("R", function() require("kulala").run_all() end, "Run all", { "n", "v" })
map("a", function() require("kulala").replay() end, "Replay")
map("q", function() require("kulala").close() end, "Close")
map("t", function() require("kulala").toggle_view() end, "Toggle View")
map("s", function() require("kulala").show_stats() end, "Show Stats")
map("i", function() require("kulala").inspect() end, "Inspect")
map("g", function() require("kulala").download_graphql_schema() end, "Download GraphQL Schema")
map("c", function() require("kulala").copy() end, "Copy as cURL")
map("C", function() require("kulala").from_curl() end, "Paste from cURL")
map("b", function() require("kulala").scratchpad() end, "Scratchpad")
map("n", function() require("kulala").jump_next() end, "Jump to Next Request")
map("p", function() require("kulala").jump_prev() end, "Jump to Previous Request")
