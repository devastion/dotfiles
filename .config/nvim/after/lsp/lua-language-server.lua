local home = vim.fn.expand("$HOME")
local runtime_files = vim.api.nvim_get_runtime_file("", true)
for k, v in ipairs(runtime_files) do
  if v == home .. "/.config/nvim/after" or v == home .. "/.config/nvim" then
    table.remove(runtime_files, k)
  end
end
table.insert(runtime_files, "${3rd}/luv/library")

---@type vim.lsp.Config
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = runtime_files,
      },
      diagnostics = {
        unusedLocalExclude = { "_*" },
      },
    },
  },
}
