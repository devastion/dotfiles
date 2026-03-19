local function has_words_before()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  if col == 0 then
    return false
  end
  local line = vim.api.nvim_get_current_line()
  return line:sub(col, col):match("%s") == nil
end

require("devastion.utils.pkg").add({
  "rafamadriz/friendly-snippets",
  "moyiz/blink-emoji.nvim",
  "dynge/gitmoji.nvim",
  {
    src = "saghen/blink.cmp",
    version = vim.version.range("1.*"),
    data = {
      event = { "InsertEnter", "CmdlineEnter" },
      task = function(p)
        vim.notify("Building blink.cmp", vim.log.levels.INFO)
        local obj = vim.system({ "cargo", "build", "--release" }, { cwd = p.spec.path }):wait()
        if obj.code == 0 then
          vim.notify("Building blink.cmp done", vim.log.levels.INFO)
        else
          vim.notify("Building blink.cmp failed", vim.log.levels.ERROR)
        end
      end,
      config = function()
        require("blink.cmp").setup({
          keymap = {
            preset = "none",
            ["<esc>"] = {
              function(cmp)
                if cmp.is_visible() and cmp.get_selected_item() ~= nil then
                  return cmp.cancel()
                else
                  return
                end
              end,
              "fallback",
            },
            ["<c-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<a-s>"] = {
              function(cmp)
                cmp.show({ providers = { "snippets" } })
              end,
            },
            ["<a-l>"] = {
              function(cmp)
                cmp.show({ providers = { "lsp" } })
              end,
            },
            ["<a-b>"] = {
              function(cmp)
                cmp.show({ providers = { "buffer" } })
              end,
            },
            ["<a-p>"] = {
              function(cmp)
                cmp.show({ providers = { "path" } })
              end,
            },
            ["<cr>"] = { "accept", "fallback" },
            ["<c-e>"] = { "hide", "fallback" },
            ["<tab>"] = {
              "snippet_forward",
              "select_next",
              function(cmp)
                if has_words_before() or vim.api.nvim_get_mode().mode == "c" then
                  return cmp.show()
                end
              end,
              "fallback",
            },
            ["<s-tab>"] = {
              "snippet_backward",
              "select_prev",
              function(cmp)
                if vim.api.nvim_get_mode().mode == "c" then
                  return cmp.show()
                end
              end,
              "fallback",
            },
            ["<c-p>"] = { "select_prev", "fallback_to_mappings" },
            ["<c-n>"] = { "select_next", "fallback_to_mappings" },
            ["<c-b>"] = { "scroll_documentation_up", "fallback" },
            ["<c-f>"] = { "scroll_documentation_down", "fallback" },
            ["<c-u>"] = { "scroll_signature_up", "fallback" },
            ["<c-d>"] = { "scroll_signature_down", "fallback" },
            ["<c-s>"] = { "show_signature", "hide_signature", "fallback" },
            ["<a-1>"] = {
              function(cmp)
                cmp.accept({ index = 1 })
              end,
            },
            ["<a-2>"] = {
              function(cmp)
                cmp.accept({ index = 2 })
              end,
            },
            ["<a-3>"] = {
              function(cmp)
                cmp.accept({ index = 3 })
              end,
            },
            ["<a-4>"] = {
              function(cmp)
                cmp.accept({ index = 4 })
              end,
            },
            ["<a-5>"] = {
              function(cmp)
                cmp.accept({ index = 5 })
              end,
            },
            ["<a-6>"] = {
              function(cmp)
                cmp.accept({ index = 6 })
              end,
            },
            ["<a-7>"] = {
              function(cmp)
                cmp.accept({ index = 7 })
              end,
            },
            ["<a-8>"] = {
              function(cmp)
                cmp.accept({ index = 8 })
              end,
            },
            ["<a-9>"] = {
              function(cmp)
                cmp.accept({ index = 9 })
              end,
            },
            ["<a-0>"] = {
              function(cmp)
                cmp.accept({ index = 10 })
              end,
            },
          },
          fuzzy = {
            frecency = {
              enabled = true,
            },
            sorts = {
              "exact",
              "score",
              "sort_text",
            },
            implementation = "rust",
          },
          completion = {
            keyword = {
              range = "full",
            },
            accept = {
              auto_brackets = {
                enabled = true,
              },
            },
            list = { selection = { preselect = false, auto_insert = true } },
            menu = {
              auto_show = function()
                return not vim.snippet.active()
              end,
              border = vim.g.border_style,
              max_height = 15,
              scrolloff = 0,
              draw = {
                align_to = "none",
                padding = 0,
                treesitter = { "lsp" },
                columns = {
                  { "item_idx" },
                  { "kind_icon" },
                  { "label", "label_description", gap = 1 },
                  { "kind", "source_name", gap = 1 },
                },
                components = {
                  source_name = {
                    text = function(ctx)
                      return "[" .. ctx.source_name .. "]"
                    end,
                  },
                  kind_icon = {
                    ellipsis = false,
                    text = function(ctx)
                      local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                      return kind_icon
                    end,
                    highlight = function(ctx)
                      local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                      return hl
                    end,
                  },
                  kind = {
                    highlight = function(ctx)
                      local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                      return hl
                    end,
                  },
                  item_idx = {
                    text = function(ctx)
                      return ctx.idx == 10 and "0" or ctx.idx >= 10 and " " or tostring(ctx.idx)
                    end,
                    highlight = "BlinkCmpItemIdx",
                  },
                },
              },
            },
            documentation = {
              auto_show = true,
              auto_show_delay_ms = 0,
              update_delay_ms = 100,
              treesitter_highlighting = true,
              window = {
                border = vim.g.border_style,
              },
            },
            trigger = {
              show_on_blocked_trigger_characters = {},
            },
          },
          signature = {
            enabled = true,
            window = {
              border = vim.g.border_style,
            },
          },
          appearance = {
            nerd_font_variant = "normal",
          },
          sources = {
            default = function()
              local success, node = pcall(vim.treesitter.get_node)
              if success and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
                return { "buffer" }
              else
                return {
                  "lsp",
                  "snippets",
                  "path",
                  "buffer",
                  "emoji",
                }
              end
            end,
            per_filetype = {
              lua = { inherit_defaults = true, "lazydev" },
              gitcommit = { inherit_defaults = true, "gitmoji" },
            },
            providers = {
              buffer = {
                opts = {
                  get_bufnrs = function()
                    return vim.tbl_filter(function(bufnr)
                      return vim.bo[bufnr].buftype == ""
                    end, vim.api.nvim_list_bufs())
                  end,
                },
              },
              lsp = {
                fallbacks = {},
              },
              snippets = {
                opts = {
                  friendly_snippets = true,
                  global_snippets = { "all", "global" },

                  extended_filetypes = {
                    sh = { "shelldoc" },
                    php = { "phpdoc" },
                  },
                },
              },
              lazydev = {
                name = "LazyDev",
                module = "lazydev.integrations.blink",
                score_offset = 100, -- show at a higher priority than lsp
              },
              emoji = {
                module = "blink-emoji",
                name = "Emoji",
                score_offset = 15, -- Tune by preference
                opts = {
                  insert = true, -- Insert emoji (default) or complete its name
                  ---@type string|table|fun():table
                  trigger = function()
                    return { ":" }
                  end,
                },
              },
              gitmoji = {
                name = "gitmoji",
                module = "gitmoji.blink",
                opts = { -- gitmoji config values goes here
                  filetypes = { "gitcommit", "jj" },
                },
              },
            },
          },
          cmdline = {
            enabled = true,
            keymap = {
              preset = "none",
              ["<cr>"] = { "accept_and_enter", "fallback" },
              ["<tab>"] = {
                function(cmp)
                  if cmp.is_ghost_text_visible() and not cmp.is_menu_visible() then
                    return cmp.accept()
                  end
                end,
                "show_and_insert",
                "select_next",
              },
              ["<S-tab>"] = { "show_and_insert", "select_prev" },
              ["<c-space>"] = { "show", "fallback" },
              ["<c-n>"] = { "select_next", "fallback" },
              ["<c-p>"] = { "select_prev", "fallback" },
              ["<a-1>"] = {
                function(cmp)
                  cmp.accept({ index = 1 })
                end,
              },
              ["<a-2>"] = {
                function(cmp)
                  cmp.accept({ index = 2 })
                end,
              },
              ["<a-3>"] = {
                function(cmp)
                  cmp.accept({ index = 3 })
                end,
              },
              ["<a-4>"] = {
                function(cmp)
                  cmp.accept({ index = 4 })
                end,
              },
              ["<a-5>"] = {
                function(cmp)
                  cmp.accept({ index = 5 })
                end,
              },
              ["<a-6>"] = {
                function(cmp)
                  cmp.accept({ index = 6 })
                end,
              },
              ["<a-7>"] = {
                function(cmp)
                  cmp.accept({ index = 7 })
                end,
              },
              ["<a-8>"] = {
                function(cmp)
                  cmp.accept({ index = 8 })
                end,
              },
              ["<a-9>"] = {
                function(cmp)
                  cmp.accept({ index = 9 })
                end,
              },
              ["<a-0>"] = {
                function(cmp)
                  cmp.accept({ index = 10 })
                end,
              },
            },
            completion = {
              menu = { auto_show = true },
              ghost_text = { enabled = true },
              list = {
                selection = { preselect = false, auto_insert = true },
              },
            },
          },
        })
      end,
    },
  },
})
