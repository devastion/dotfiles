---@type LazySpec
return {
  "mfussenegger/nvim-lint",
  lazy = true,
  opts = {
    linters_by_ft = {
      ghaction = { "actionlint" },
      dotenv = { "dotenv_linter" },
      php = vim.g.is_laravel_project and {} or { "phpcs" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
    },
  },
  config = function(_, opts)
    local lint = require("lint")
    lint.linters_by_ft = opts.linters_by_ft

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function(event)
        if vim.opt_local.modifiable:get() and (vim.g.autolint_enabled or vim.b[event.buf].autolint_enabled) then
          local names = lint._resolve_linter_by_ft(vim.bo.filetype)

          names = vim.list_extend({}, names)

          if #names == 0 then
            vim.list_extend(names, lint.linters_by_ft["_"] or {})
          end

          vim.list_extend(names, lint.linters_by_ft["*"] or {})

          if #names > 0 then
            for _, name in ipairs(names) do
              local cmd = vim.fn.executable(name)
              if cmd == 0 then
                vim.notify("Linter " .. name .. " is not available", vim.log.levels.INFO)
                return
              else
                lint.try_lint(name)
              end
            end
          end
        end
      end,
    })
  end,
  keys = function()
    local lint = require("lint")
    local ns = require("lint").get_namespace("cspell")

    return {
      {
        "<leader>cl",
        function()
          lint.try_lint()
        end,
        desc = "Lint",
        mode = { "n", "v" },
      },
      {
        "<leader>cs",
        function()
          lint.try_lint("cspell")
        end,
        desc = "Lint with CSpell",
        mode = { "n", "v" },
      },
      {
        "<leader>cS",
        function()
          vim.diagnostic.reset(ns, vim.api.nvim_win_get_buf(0))
        end,
        desc = "Clear CSpell Diagnostics",
        mode = { "n", "v" },
      },
    }
  end,
}
