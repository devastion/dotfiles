---@type LazySpec
return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {},
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

          -- Create a copy of the names table to avoid modifying the original.
          names = vim.list_extend({}, names)

          -- Add fallback linters.
          if #names == 0 then
            vim.list_extend(names, lint.linters_by_ft["_"] or {})
          end

          -- Add global linters.
          vim.list_extend(names, lint.linters_by_ft["*"] or {})

          -- Run linters.
          if #names > 0 then
            -- Check the if the linter is available, otherwise it will throw an error.
            for _, name in ipairs(names) do
              local cmd = vim.fn.executable(name)
              if cmd == 0 then
                vim.notify("Linter " .. name .. " is not available", vim.log.levels.INFO)
                return
              else
                -- Run the linter
                lint.try_lint(name)
              end
            end
          end
        end
      end,
    })

    vim.keymap.set("n", "<leader>cl", function() lint.try_lint() end, { desc = "Lint" })
  end,
  init = function() vim.g.autolint_enabled = false end,
}
