vim.pack.add(
  { { src = "https://github.com/jbyuki/one-small-step-for-vimkind", version = "84689d9e" } },
  { confirm = false }
)

vim.g.mason_install({ "lua-language-server", "stylua", "selene" })
vim.g.ts_install({ "lua", "luadoc", "luap" })

require("conform").formatters_by_ft.lua = { "stylua" }
vim.b.autoformat_enabled = true

if vim.g.is_selene_config_available then
  require("lint").linters_by_ft.lua = { "selene" }
  vim.b.autolint_enabled = true
end

local status_ok, dap = pcall(require, "dap")
if not status_ok then
  return
end

dap.adapters.nlua = function(callback, conf)
  local adapter = {
    type = "server",
    host = conf.host or "127.0.0.1",
    port = conf.port or 8086,
  }
  if conf.start_neovim then
    local dap_run = dap.run
    dap.run = function(c)
      adapter.port = c.port
      adapter.host = c.host
    end
    require("osv").run_this()
    dap.run = dap_run
  end
  callback(adapter)
end
dap.configurations.lua = {
  {
    type = "nlua",
    request = "attach",
    name = "Run this file",
    start_neovim = {},
  },
  {
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim instance (port = 8086)",
    port = 8086,
  },
}
