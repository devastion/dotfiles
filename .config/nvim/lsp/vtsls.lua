return {
  cmd = { "vtsls", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    -- "vue",
  },
  root_markers = {
    "tsconfig.json",
    "package.json",
    "jsconfig.json",
    ".git",
  },
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = false,
      tsserver = {
        globalPlugin = {
          -- Not working well on vue 2
          -- {
          --   name = "@vue/typescript-plugin",
          --   location = vim.fn.exepath("vue-language-server"),
          --   -- location = require("mason-registry").get_package("vue-language-server"):get_install_path()
          --   --   .. "/node_modules/@vue/language-server",
          --   languages = { "vue" },
          --   configNamespace = "typescript",
          --   enableForWorkspaceTypeScriptVersions = true,
          -- },
          {
            name = "@astrojs/ts-plugin",
            location = vim.fn.exepath("astro-language-server"),
            -- location = require("mason-registry").get_package("astro-language-server"):get_install_path()
            --   .. "/node_modules/@astrojs/ts-plugin",
            enableForWorkspaceTypeScriptVersions = true,
          },
        },
      },
    },
  },
}
