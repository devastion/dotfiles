---@type LazySpec
return {
  "mfussenegger/nvim-lint",
  lazy = true,
  opts = {
    linters = {
      phpstan_docker = function()
        local container_id = Devastion.docker.get_container_id("php")
        local file_name = vim.fn.fnamemodify(vim.fn.bufname("%"), ":.")

        return {
          name = "phpstan_docker",
          cmd = "docker",
          args = {
            "exec",
            "-i",
            "-w",
            "/var/www/html",
            container_id,
            "/bin/sh",
            "-c",
            "php vendor/bin/phpstan analyze --error-format=json --no-progress --memory-limit=2G " .. file_name,
          },
          stdin = false,
          append_fname = false,
          ignore_exitcode = true,
          parser = function(output, bufnr)
            if vim.trim(output) == "" or output == nil then
              return {}
            end

            local file_name = "/var/www/html/" .. vim.fn.fnamemodify(vim.fn.bufname(bufnr), ":.")
            local file = vim.json.decode(output).files[file_name]

            if file == nil then
              return {}
            end

            local diagnostics = {}

            for _, message in ipairs(file.messages or {}) do
              table.insert(diagnostics, {
                lnum = type(message.line) == "number" and (message.line - 1) or 0,
                col = 0,
                message = message.message,
                source = "phpstan_docker",
                code = message.identifier,
              })
            end

            return diagnostics
          end,
        }
      end,
    },
    linters_by_ft = {
      ["*"] = { "editorconfig-checker" },
      ghaction = { "actionlint" },
      dotenv = { "dotenv_linter" },
      php = vim.g.is_laravel_project and { "phpstan_docker" } or { "phpcs" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      dockerfile = { "hadolint" },
      markdown = { "markdownlint-cli2" },
      sql = { "sqlfluff" },
      pgsql = { "sqlfluff" },
      mysql = { "sqlfluff" },
      plsql = { "sqlfluff" },
      yaml = { "yamllint" },
      lua = { "luacheck" },
    },
  },
  config = function(_, opts)
    local lint = require("lint")
    lint.linters.phpstan_docker = opts.linters.phpstan_docker
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
              if cmd == 0 and string.find(cmd, "docker") ~= nil then
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
