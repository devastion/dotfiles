vim.g.mason_install({ "marksman" })
vim.g.ts_install({ "markdown", "markdown_inline" })

---@type vim.lsp.Config
return {
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx" },
  root_markers = { ".marksman.toml", ".git" },
}
