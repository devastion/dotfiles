---@type LazySpec
return {
  "jiaoshijie/undotree",
  -- INFO: Replace with fzf-lua
  enabled = false,
  lazy = true,
  opts = {},
  keys = {
    {
      "<leader>U",
      function()
        require("undotree").toggle()
      end,
      desc = "Undotree Toggle",
      noremap = true,
    },
  },
  init = function()
    vim.api.nvim_create_user_command("Undotree", function(opts)
      local args = opts.fargs
      local cmd = args[1]

      if cmd == "toggle" then
        require("undotree").toggle()
      elseif cmd == "open" then
        require("undotree").open()
      elseif cmd == "close" then
        require("undotree").close()
      else
        vim.notify("Invalid subcommand: " .. (cmd or ""), vim.log.levels.ERROR)
      end
    end, {
      nargs = 1,
      complete = function(_, line)
        local subcommands = { "toggle", "open", "close" }
        local input = vim.split(line, "%s+")
        local prefix = input[#input]

        return vim.tbl_filter(function(cmd)
          return vim.startswith(cmd, prefix)
        end, subcommands)
      end,
      desc = "Undotree command with subcommands: toggle, open, close",
    })
  end,
}
