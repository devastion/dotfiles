local utils = require("devastion.utils")

utils.autocmd("PackChanged", {
  group = utils.augroup("pack_changed"),
  pattern = "*",
  callback = function(event)
    local p = event.data
    local task = (p.spec.data or {}).task
    if p.kind ~= "delete" and type(task) == "function" then
      pcall(task, p)

      vim.notify("Updated " .. p.spec.name, vim.log.levels.INFO)
    end
  end,
})

require("devastion.config")
