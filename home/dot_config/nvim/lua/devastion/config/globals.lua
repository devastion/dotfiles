vim.g.mapleader = vim.keycode("<space>")
vim.g.maplocalleader = vim.keycode("<bslash>")

-- Disable built-in ftplugin mappings
vim.g.no_plugin_maps = true

vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- UI
vim.g.diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = "✘",
  [vim.diagnostic.severity.WARN] = "▲",
  [vim.diagnostic.severity.HINT] = "⚑",
  [vim.diagnostic.severity.INFO] = "»",
}
vim.g.border_style = "single"

local luarocks_args = { "--lua-version", "5.1", "path" }

vim.system({ "luarocks", unpack(luarocks_args), "--lr-path" }, { text = true }, function(out)
  local path = vim.trim(out.stdout or "")
  if path ~= "" then
    package.path = package.path .. ";" .. path
  end
end)

vim.system({ "luarocks", unpack(luarocks_args), "--lr-cpath" }, { text = true }, function(out)
  local cpath = vim.trim(out.stdout or "")
  if cpath ~= "" then
    package.cpath = package.cpath .. ";" .. cpath
  end
end)
