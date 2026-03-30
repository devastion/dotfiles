local map = require("devastion.utils").map
local file_exists = require("devastion.utils.fs").file_exists

require("devastion.utils.pkg").add({
  {
    src = "stevearc/conform.nvim",
    data = {
      event = { "BufReadPost", "BufWritePost", "BufNewFile" },
      init = function()
        vim.g.ENABLE_AUTOFORMAT = vim.g.ENABLE_AUTOFORMAT or false
      end,
      config = function()
        require("conform").setup({
          default_format_opts = {
            timeout_ms = 3000,
            async = true,
            quiet = false,
            lsp_format = "fallback",
            stop_after_first = false,
          },
          formatters_by_ft = {
            lua = { "stylua" },
            bash = { "shfmt" },
            sh = { "shfmt" },
            zsh = { "shfmt" },
            blade = { "blade-formatter" },
            php = file_exists("artisan") and { "pint" } or {},
            graphql = { "prettier" },
            python = { "black" },
            markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
            ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
            dockerfile = { "dockerfmt" },
            yaml = { "yamlfmt" },
            toml = { "taplo" },
            templ = { "templ" },
          },
          format_on_save = function(bufnr)
            local is_autoformat_enabled = vim.b[bufnr].ENABLE_AUTOFORMAT == nil and vim.g.ENABLE_AUTOFORMAT
              or vim.b[bufnr].ENABLE_AUTOFORMAT

            if is_autoformat_enabled then
              return { timeout_ms = 3000, lsp_format = "fallback" }
            end
          end,
          formatters = {
            injected = { options = { ignore_errors = true } },
            ["markdown-toc"] = {
              condition = function(_, ctx)
                for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
                  if line:find("<!%-%- toc %-%->") then
                    return true
                  end
                end
                return false
              end,
            },
            ["markdownlint-cli2"] = {
              condition = function(_, ctx)
                local diag = vim.tbl_filter(function(d)
                  return d.source == "markdownlint"
                end, vim.diagnostic.get(ctx.buf))
                return #diag > 0
              end,
            },
          },
        })
        require("conform").formatters.yamlfmt = {
          prepend_args = function(self, ctx)
            return { "-formatter", "retain_line_breaks_single=true" }
          end,
        }

        require("devastion.utils.pkg").mason_install(vim.tbl_values(require("conform").formatters_by_ft))

        map("<leader>cf", function()
          require("conform").format({ async = true }, function(err)
            if not err then
              local mode = vim.api.nvim_get_mode().mode
              if vim.startswith(string.lower(mode), "v") then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
              end
            end
          end)
        end, "Format", { "n", "x" })

        map("<leader>cF", function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end, "Format Injected Langs", { "n", "v" })

        map("<Leader>uf", function()
          vim.b.ENABLE_AUTOFORMAT = not vim.b.ENABLE_AUTOFORMAT
          vim.notify(
            (vim.b.ENABLE_AUTOFORMAT and "Enabled" or "Disabled") .. " autoformat for current buffer",
            vim.log.levels.INFO
          )
        end, "Toggle Format (buffer)")

        map("<Leader>uF", function()
          vim.g.ENABLE_AUTOFORMAT = not vim.g.ENABLE_AUTOFORMAT
          vim.notify(
            (vim.g.ENABLE_AUTOFORMAT and "Enabled" or "Disabled") .. " autoformat (global)",
            vim.log.levels.INFO
          )
        end, "Toggle Format (global)")
      end,
    },
  },
})
