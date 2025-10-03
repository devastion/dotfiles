vim.pack.add({ "https://github.com/chrisgrieser/nvim-spider" }, { confirm = false })

local spider = require("spider")

spider.setup({
  skipInsignificantPunctuation = true,
  consistentOperatorPending = true,
  subwordMovement = true,
  customPatterns = {},
})

local map = require("devastion.utils").remap

map("w", function() spider.motion("w") end, nil, { "n", "x", "o" })
map("e", function() spider.motion("e") end, nil, { "n", "x", "o" })
map("b", function() spider.motion("b") end, nil, { "n", "x", "o" })
map("cw", "c<cmd>lua require('spider').motion('e')<CR>")
map("<C-f>", "<Esc>l<cmd>lua require('spider').motion('w')<CR>i", nil, "i")
map("<C-b>", "<Esc>l<cmd>lua require('spider').motion('b')<CR>i", nil, "i")
