return {
  cmd = { "vue-language-server", "--stdio" },
  filetypes = { "vue" },
  root_markers = {
    "package.json",
    ".git",
  },
  init_options = {
    vue = {
      hybridMode = false,
    },
    typescript = {
      tsdk = vim.fn.stdpath("data")
        .. "/mason/packages/vtsls/node_modules/@vtsls/language-server/node_modules/typescript/lib",
    },
  },
}
