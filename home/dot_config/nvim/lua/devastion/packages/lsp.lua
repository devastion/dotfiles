local map = require("devastion.utils").map
local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup

local enabled_lsp = {
  "ansiblels",
  "basedpyright",
  "bashls",
  "clangd",
  "copilot",
  "cssls",
  "dockerls",
  "eslint",
  "fish_lsp",
  "graphql",
  "harper_ls",
  "html",
  "intelephense",
  "jsonls",
  "lua_ls",
  "marksman",
  "pkl-lsp",
  "taplo",
  "vtsls",
  "vue_ls",
  "yamlls",
}

local mason_lsp = {
  "amber-lsp",
  "ansible-language-server",
  "basedpyright",
  "bash-language-server",
  "clangd",
  "copilot-language-server",
  "cspell-lsp",
  "css-lsp",
  "docker-language-server",
  "eslint-lsp",
  "fish-lsp",
  "graphql-language-service-cli",
  "harper-ls",
  "html-lsp",
  "intelephense",
  "json-lsp",
  "lua-language-server",
  "marksman",
  "pkl-lsp",
  "taplo",
  "vtsls",
  "vue-language-server",
  "yaml-language-server",
}

require("devastion.utils.pkg").mason_install(mason_lsp)

require("devastion.utils.pkg").add({
  "b0o/schemastore.nvim",
  {
    src = "neovim/nvim-lspconfig",
    version = vim.version.range("*"),
    data = {
      event = { "BufReadPre", "BufWritePost", "BufNewFile" },
      config = function()
        vim.lsp.config("jsonls", {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        })

        vim.lsp.config("yamlls", {
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              schemaStore = {
                enable = false,
                url = "",
              },
              schemas = require("schemastore").yaml.schemas(),
            },
          },
        })

        vim.lsp.config("lua_ls", {
          root_markers = {
            ".emmyrc.json",
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
              diagnostics = {
                disable = { "missing-fields", "incomplete-signature-doc" },
                unusedLocalExclude = { "_*" },
              },
            },
          },
        })

        vim.lsp.config("vtsls", {
          settings = {
            vtsls = {
              tsserver = {
                globalPlugins = {
                  {
                    name = "@vue/typescript-plugin",
                    location = vim.fn.stdpath("data")
                      .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                    languages = { "vue" },
                    configNamespace = "typescript",
                  },
                },
              },
            },
          },
          filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" },
        })

        vim.lsp.config("harper_ls", {
          settings = {
            ["harper-ls"] = {
              userDictPath = vim.fn.stdpath("config") .. "/spell/harper_dictionary.txt",
            },
          },
        })

        vim.lsp.config("eslint", {
          on_attach = function()
            local disabled_formatting_lsp = { "vue_ls", "vtsls" }
            local clients = vim.lsp.get_clients()

            for _, client in ipairs(clients) do
              if vim.tbl_contains(disabled_formatting_lsp, client.name) then
                client.server_capabilities.documentFormattingProvider = false
                vim.notify(string.format("Disabled formatting for: %s", client.name), vim.log.levels.INFO)
              end
            end
          end,
        })

        vim.lsp.config("intelephense", {
          settings = {
            intelephense = {
              maxSize = 2000000,
            },
          },
        })

        vim.lsp.config("copilot", {
          handlers = {
            ["window/showMessageRequest"] = function(_, result)
              if result and result.message and result.message:find("limit") then
                return vim.NIL
              end
              return vim.lsp.handlers["window/showMessageRequest"](_, result, {})
            end,
          },
        })

        vim.lsp.config("bashls", {
          filetypes = { "bash", "sh", "zsh" },
        })

        vim.lsp.enable(enabled_lsp)
      end,
    },
  },
  {
    src = "folke/lazydev.nvim",
    data = {
      event = { "FileType" },
      pattern = { "lua" },
      config = function()
        local lazydev = require("lazydev")
        lazydev.setup({
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        })
      end,
    },
  },
  "saecki/live-rename.nvim",
  {
    src = "artemave/workspace-diagnostics.nvim",
    data = {
      config = function()
        map("<leader>cx", function()
          for _, client in ipairs(vim.lsp.get_clients()) do
            require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
          end
        end, "Workspace Diagnostics")
      end,
    },
  },
  {
    src = "nemanjamalesija/ts-expand-hover.nvim",
    data = {
      event = { "FileType" },
      pattern = { "typescript", "typescriptreact" },
      config = function()
        require("ts_expand_hover").setup({
          keymaps = {
            hover = false,
          },
        })
      end,
    },
  },
  {
    src = "apple/pkl-neovim",
    data = {
      config = function()
        require("pkl-neovim").init({})
        vim.g.pkl_neovim = {
          start_command = { "pkl-lsp" },
        }
      end,
    },
  },
})

local default_keymaps = {
  n = { "gra", "gri", "grn", "grr", "grt", "gO" },
  i = { "<c-s>" },
}

for m, keys in pairs(default_keymaps) do
  for _, key in ipairs(keys) do
    vim.keymap.del(m, key)
  end
end

local function fzf_lsp_keymaps(buf)
  map("gri", function()
    require("fzf-lua").lsp_implementations()
  end, "Implementations", "n", { buffer = buf })

  map("gd", function()
    require("fzf-lua").lsp_definitions({ jump1 = true })
  end, "Definitions", "n", { buffer = buf })

  map("grd", function()
    require("fzf-lua").lsp_declarations({ jump_to_single_result = true })
  end, "Declarations", "n", { buffer = buf })

  map("grr", function()
    require("fzf-lua").lsp_references({ ignore_current_line = true, includeDeclaration = false })
  end, "References", "n", { buffer = buf })

  map("gra", function()
    require("fzf-lua").lsp_code_actions()
  end, "Code Action", "n", { buffer = buf })

  map("grI", function()
    require("fzf-lua").lsp_typedefs()
  end, "Type Definitions", "n", { buffer = buf })

  map("grT", function()
    require("fzf-lua").lsp_type_super()
  end, "Super Types", "n", { buffer = buf })

  map("grt", function()
    require("fzf-lua").lsp_type_sub()
  end, "Sub Types", "n", { buffer = buf })

  map("gO", function()
    require("fzf-lua").lsp_document_symbols()
  end, "LSP Document Symbols", "n", { buffer = buf })

  map("grf", function()
    require("fzf-lua").lsp_finder()
  end, "LSP Finder", "n", { buffer = buf })
end

autocmd("LspAttach", {
  group = augroup("lsp_attach"),
  callback = function(event)
    local buf = event.buf
    local filetype = vim.bo[buf].filetype

    map("grn", function()
      require("live-rename").rename()
    end, "Rename", "n", { buffer = buf })

    map("K", function()
      if (filetype == "typescript" or filetype == "typescriptreact") and package.loaded["ts_expand_hover"] then
        require("ts_expand_hover").hover()
      else
        vim.lsp.buf.hover({ border = vim.g.border_style })
      end
    end, "Hover", "n", { buffer = buf })

    fzf_lsp_keymaps(buf)
  end,
})
