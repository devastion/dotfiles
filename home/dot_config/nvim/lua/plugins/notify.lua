vim.pack.add({ 'https://github.com/rcarriga/nvim-notify' }, { confirm = false })

local notify = require('notify')

notify.setup({
  render = 'default',
  stages = 'static',
})

local ignore = {
  'No information available',
}

---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, o)
  if type(msg) == 'string' then
    for _, pat in ipairs(ignore) do
      if msg:find(pat) then return end
    end
  end
  return notify(msg, level, o)
end
