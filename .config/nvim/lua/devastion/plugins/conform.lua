---@type LazySpec
return {
  "stevearc/conform.nvim",
  lazy = true,
  cmd = {
    "ConformInfo",
  },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true }, function(err)
          if not err then
            local mode = vim.api.nvim_get_mode().mode
            if vim.startswith(string.lower(mode), "v") then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
            end
          end
        end)
      end,
      mode = { "n", "x" },
      desc = "Format",
    },
    {
      "<leader>cF",
      function()
        require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
      end,
      mode = { "n", "v" },
      desc = "Format Injected Langs",
    },
  },
  opts = function()
    return {
      default_format_opts = {
        timeout_ms = 3000,
        async = true,
        quiet = false,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        bash = { "shfmt" },
        sh = { "shfmt" },
        blade = { "blade-formatter" },
        php = vim.g.is_laravel_project and { "pint" } or { "php_cs_fixer" },
        graphql = { "prettier" },
        python = { "black" },
        markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
        ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
        sql = { "sqlfluff" },
        pgsql = { "sqlfluff" },
        mysql = { "sqlfluff" },
        plsql = { "sqlfluff" },
      },
      stop_after_first = true,
      formatters = {
        injected = { options = { ignore_errors = true } },
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
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
        sqlfluff = {
          command = "sqlfluff",
          args = {
            "format",
            "-n",
            "--dialect=ansi",
            "--disable-progress-bar",
            "-",
          },
          stdin = true,
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
      },
      format_on_save = function(bufnr)
        if vim.g.autoformat_enabled or vim.b[bufnr].autoformat_enabled then
          return { timeout_ms = 3000, lsp_format = "fallback" }
        end
      end,
    }
  end,
}
