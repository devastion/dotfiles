local usercmd = require("devastion.utils").usercmd

usercmd("W", function()
  vim.notify("Write without autocmds", vim.log.levels.INFO)
  vim.cmd([[noa write]])
end, { desc = "Write Buffer without AutoCommands" })

usercmd("ListLspAttachedClients", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP clients active", vim.log.levels.WARN)
    return
  end

  local names = vim
    .iter(clients)
    :map(function(c)
      return c.name
    end)
    :totable()
  vim.notify("[" .. table.concat(names, ", ") .. "]", vim.log.levels.INFO)
end, { desc = "List LSP Attached Clients" })

local pack_subcommands = {
  uninstall = require("devastion.utils.pkg").uninstall,
  prune = require("devastion.utils.pkg").prune,
  update = require("devastion.utils.pkg").update,
  updateAll = require("devastion.utils.pkg").updateAll,
}

vim.api.nvim_create_user_command("Pack", function(opts)
  local fn = pack_subcommands[opts.args]
  if fn then
    fn()
  else
    vim.notify("Pack: unknown subcommand '" .. opts.args .. "'", vim.log.levels.ERROR)
  end
end, {
  nargs = 1,
  complete = function()
    return vim.tbl_keys(pack_subcommands)
  end,
})
