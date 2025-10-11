vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/andythigpen/nvim-coverage",
}, { confirm = false })

require("coverage").setup({
  auto_reload = true,
})

local handle = io.popen("luarocks path --lr-cpath")

if handle then
  local lr_cpath = handle:read("*a"):gsub("%s+$", "")
  handle:close()

  package.cpath = package.cpath .. ";" .. lr_cpath
end

if vim.g.is_laravel_project then
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = { "*.php" },
    once = true,
    callback = function()
      vim.schedule(function() require("coverage").load(true) end)
    end,
  })
end

vim.keymap.set("n", "<leader>tc", function() require("coverage").toggle() end, { desc = "Toggle Coverage" })
