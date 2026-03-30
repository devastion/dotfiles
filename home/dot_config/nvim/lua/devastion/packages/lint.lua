local map = require("devastion.utils").map
local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup
local file_exists = require("devastion.utils.fs").file_exists

require("devastion.utils.pkg").add({
  {
    src = "mfussenegger/nvim-lint",
    data = {
      event = { "BufReadPost", "BufWritePost", "BufNewFile" },
      init = function()
        vim.g.ENABLE_AUTOLINT = vim.g.ENABLE_AUTOLINT or false
      end,
      config = function()
        local lint = require("lint")

        local linters_by_ft = {
          ["*"] = { "editorconfig-checker" },
          lua = file_exists("selene.toml") and { "selene" } or {},
          ghaction = { "actionlint" },
          dotenv = { "dotenv_linter" },
          php = file_exists("artisan") and { "phpstan" } or { "phpcs" },
          sh = { "shellcheck" },
          bash = { "shellcheck" },
          dockerfile = { "hadolint" },
          markdown = { "markdownlint-cli2" },
          yaml = { "yamllint" },
          ["yaml.github"] = { "actionlint" },
          go = { "golangcilint" },
        }

        lint.linters_by_ft = linters_by_ft

        require("devastion.utils.pkg").mason_install(vim.tbl_values(linters_by_ft))

        autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
          group = augroup("nvim_lint"),
          callback = function(event)
            local is_autolint_enabled = vim.b[event.buf].ENABLE_AUTOLINT == nil and vim.g.ENABLE_AUTOLINT
              or vim.b[event.buf].ENABLE_AUTOLINT

            if is_autolint_enabled then
              if vim.opt_local.modifiable:get() then
                local names = lint._resolve_linter_by_ft(vim.bo.filetype)
                names = vim.list_extend({}, names)
                if #names == 0 then
                  vim.list_extend(names, lint.linters_by_ft["_"] or {})
                end
                vim.list_extend(names, lint.linters_by_ft["*"] or {})
                if #names > 0 then
                  lint.try_lint(names)
                end
              end
            end
          end,
        })

        map("<leader>cl", function()
          require("lint").try_lint()
        end, "Lint", { "n", "v" })

        map("<Leader>ul", function()
          vim.b.ENABLE_AUTOLINT = not vim.b.ENABLE_AUTOLINT
          vim.notify(
            (vim.b.ENABLE_AUTOLINT and "Enabled" or "Disabled") .. " autolint for current buffer",
            vim.log.levels.INFO
          )
        end, "Toggle Lint (buffer)")
        map("<Leader>uL", function()
          vim.g.ENABLE_AUTOLINT = not vim.g.ENABLE_AUTOLINT
          vim.notify(
            (vim.g.ENABLE_AUTOLINT and "Enabled" or "Disabled") .. " autolint for current buffer",
            vim.log.levels.INFO
          )
        end, "Toggle Lint (global)")
      end,
    },
  },
})
