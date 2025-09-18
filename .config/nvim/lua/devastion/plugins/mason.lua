vim.pack.add({ "https://github.com/mason-org/mason.nvim" }, { confirm = false })

require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
    border = "single",
    width = 0.8,
    height = 0.8,
  },
})

vim.keymap.set("n", "<leader>cm", function() require("mason.api.command").Mason() end, { desc = "Mason" })

---Install packages with mason
---@param packages table<string>
vim.g.mason_install = function(packages)
  local mr = require("mason-registry")
  mr.refresh(function()
    for _, tool in ipairs(packages) do
      local p = mr.get_package(tool)
      if not p:is_installed() then
        p:install()
      end
    end
  end)
end

vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, "/") .. ":" .. vim.env.PATH
