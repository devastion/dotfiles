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
        vim.g.enable_autolint = false
      end,
      config = function()
        local lint = require("lint")
        lint.linters.shellcheck_bash = function()
          local shellcheck = lint.linters.shellcheck
          local linter = shellcheck
          table.insert(linter.args, 1, "--shell=bash")
          table.insert(linter.args, 2, "--exclude=SC2299")
          return linter
        end

        local linters_by_ft = {
          ["*"] = { "editorconfig-checker" },
          lua = file_exists("selene.toml") and { "selene" } or {},
          ghaction = { "actionlint" },
          dotenv = { "dotenv_linter" },
          php = file_exists("artisan") and { "phpstan" } or { "phpcs" },
          sh = { "shellcheck" },
          bash = { "shellcheck" },
          zsh = { "shellcheck_bash" },
          dockerfile = { "hadolint" },
          markdown = { "markdownlint-cli2" },
          yaml = { "yamllint" },
          ["yaml.github"] = { "actionlint" },
        }

        lint.linters_by_ft = linters_by_ft

        require("devastion.utils.pkg").mason_install(vim.tbl_values(linters_by_ft))

        autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
          group = augroup("nvim_lint"),
          callback = function(event)
            local is_autolint_enabled = vim.b[event.buf].enable_autolint == nil and vim.g.enable_autolint
              or vim.b[event.buf].enable_autolint

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

        map("<Leader>uL", function()
          vim.b.enable_autolint = not vim.b.enable_autolint
          vim.notify(
            (vim.b.enable_autolint and "Enabled" or "Disabled") .. " autolint for current buffer",
            vim.log.levels.INFO
          )
        end, "Toggle Lint")
      end,
    },
  },
})
