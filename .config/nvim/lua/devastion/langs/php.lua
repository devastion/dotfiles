vim.g.laravel_enabled = require("devastion.utils.lsp").is_laravel()
vim.g.phpunit_cmd = "dphpunit"

---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "intelephense",
        "pint",
        "blade-formatter",
        "phpcs",
        "php-cs-fixer",
        "php-debug-adapter",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "php",
        "php_only",
        "phpdoc",
        "blade",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        php = vim.g.laravel_enabled and { "pint" } or { "php_cs_fixer" },
        blade = { "blade-formatter" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        php = not vim.g.laravel_enabled and { "phpcs" } or {},
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "olimorris/neotest-phpunit",
    },
    opts = function(_, opts)
      table.insert(
        opts.adapters,
        require("neotest-phpunit")({
          phpunit_cmd = function() return vim.g.phpunit_cmd end,
          env = {
            XDEBUG_CONFIG = "idekey=neotest",
          },
          ---@diagnostic disable-next-line: undefined-field
          dap = require("dap").configurations.php[1],
        })
      )
      return opts
    end,
    keys = {
      {
        "<leader>td",
        function() require("neotest").run.run({ strategy = "dap" }) end,
        desc = "Debug Nearest",
        ft = "php",
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      dap.adapters.php = {
        type = "executable",
        command = vim.fn.exepath("php-debug-adapter"),
      }
      ---@diagnostic disable-next-line: inject-field
      dap.configurations.php = {
        {
          type = "php",
          request = "launch",
          name = "Listen for XDebug",
          port = 9003,
          log = true,
          xdebugSettings = {
            max_children = 512,
            max_data = 1024,
            max_depth = 4,
          },
          breakpoints = {
            exception = {
              Notice = false,
              Warning = false,
              Error = false,
              Exception = false,
              ["*"] = false,
            },
          },
          pathMappings = {
            -- ["/var/www/html/"] = vim.fn.getcwd() .. "/",
          },
        },
      }
    end,
  },
  {
    "ricardoramirezr/blade-nav.nvim",
    ft = { "blade", "php" },
    cond = vim.g.laravel_enabled,
    opts = {
      close_tag_on_complete = true,
    },
  },
  {
    "ibhagwan/fzf-lua",
    keys = vim.g.laravel_enabled and {
      {
        "<leader>fc",
        function() require("fzf-lua").files({ cmd = "fd -g -p -t f '**/controllers/**'" }) end,
        desc = "Controllers",
      },
      {
        "<leader>fm",
        function() require("fzf-lua").files({ cmd = "fd -g -p -t f '**/models/**'" }) end,
        desc = "Models",
      },
      {
        "<leader>fs",
        function() require("fzf-lua").files({ cmd = "fd -g -p -t f '**/services/**'" }) end,
        desc = "Services",
      },
      {
        "<leader>ft",
        function() require("fzf-lua").files({ cmd = "fd -g -p -t f '**/tests/**'" }) end,
        desc = "Tests",
      },
    } or {},
  },
}
