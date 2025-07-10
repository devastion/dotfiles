---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "basedpyright",
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = function(_, opts)
      opts.adapters["neotest-python"] = opts.adapters["neotest-python"] or {}
      table.insert(opts.adapters["neotest-python"], {
        runner = "pytest",
        python = ".venv/bin/python",
      })

      return opts
    end,
  },
}
