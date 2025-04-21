---Check if there are words before cursor
---@return boolean
local function has_words_before()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  if col == 0 then
    return false
  end
  local line = vim.api.nvim_get_current_line()
  return line:sub(col, col):match("%s") == nil
end

---@type LazySpec
return {
  "saghen/blink.cmp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "echasnovski/mini.icons",
  },
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  opts = {
    keymap = {
      preset = "none",
      ["<Esc>"] = {
        function(cmp)
          if cmp.is_visible() and cmp.get_selected_item() ~= nil then
            return cmp.cancel()
          else
            return
          end
        end,
        "fallback",
      },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<Tab>"] = {
        "snippet_forward",
        "select_next",
        function(cmp)
          if has_words_before() or vim.api.nvim_get_mode().mode == "c" then
            return cmp.show()
          end
        end,
        "fallback",
      },
      ["<S-Tab>"] = {
        "snippet_backward",
        "select_prev",
        function(cmp)
          if vim.api.nvim_get_mode().mode == "c" then
            return cmp.show()
          end
        end,
        "fallback",
      },
      ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
      ["<C-n>"] = { "select_next", "fallback_to_mappings" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },
    fuzzy = {
      use_frecency = true,
      implementation = "prefer_rust_with_warning",
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
        auto_show = true,
        border = "single",
        max_height = 15,
        scrolloff = 0,
        draw = {
          align_to = "none",
          padding = 0,
          treesitter = { "lsp" },
          columns = {
            { "kind_icon" },
            { "label", "label_description", gap = 1 },
            { "source_name" },
          },
          components = {
            source_name = {
              text = function(ctx) return "[" .. ctx.source_name .. "]" end,
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
          },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 0,
        update_delay_ms = 100,
        treesitter_highlighting = true,
        window = {
          border = "single",
        },
      },
      trigger = {
        show_on_blocked_trigger_characters = {},
      },
    },
    signature = {
      enabled = true,
      window = {
        border = "single",
      },
    },
    appearance = {
      nerd_font_variant = "normal",
    },
    sources = {
      default = { "lsp", "snippets", "path", "buffer" },
      providers = {},
    },
    cmdline = {
      enabled = true,
      keymap = {
        preset = "none",
        ["<CR>"] = { "accept_and_enter", "fallback" },
        ["<Tab>"] = {
          function(cmp)
            if cmp.is_ghost_text_visible() and not cmp.is_menu_visible() then
              return cmp.accept()
            end
          end,
          "show_and_insert",
          "select_next",
        },
        ["<S-Tab>"] = { "show_and_insert", "select_prev" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
      },
      completion = {
        menu = { auto_show = true },
        list = {
          selection = { preselect = false, auto_insert = true },
        },
      },
    },
  },
}
