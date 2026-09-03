---@class BracketedMapping
---@field prev string|function
---@field next string|function
---@field prev_desc string
---@field next_desc string

---@param count -1|1
---@param severity? 'ERROR'|'WARN'|'INFO'|'HINT'
local function goto_diagnostic(count, severity)
  vim.diagnostic.jump({
    count = count,
    float = true,
    severity = severity and vim.diagnostic.severity[severity] or nil,
  })
end

---@param forward boolean
local function goto_conflict(forward)
  vim.fn.search([[^\(<<<<<<<\|=======\|>>>>>>>\)]], forward and 'W' or 'bW')
end

local config = {
  prev_prefix = '[',
  next_prefix = ']',
  ---@type table<string, BracketedMapping>
  mappings = {
    d = {
      prev = function()
        goto_diagnostic(-1)
      end,
      next = function()
        goto_diagnostic(1)
      end,
      prev_desc = 'Prev diagnostic',
      next_desc = 'Next diagnostic',
    },
    e = {
      prev = function()
        goto_diagnostic(-1, 'ERROR')
      end,
      next = function()
        goto_diagnostic(1, 'ERROR')
      end,
      prev_desc = 'Prev error',
      next_desc = 'Next error',
    },
    q = {
      prev = '<cmd>cprev<cr>',
      next = '<cmd>cnext<cr>',
      prev_desc = 'Prev quickfix item',
      next_desc = 'Next quickfix item',
    },
    Q = {
      prev = '<cmd>cfirst<cr>',
      next = '<cmd>clast<cr>',
      prev_desc = 'First quickfix item',
      next_desc = 'Last quickfix item',
    },
    l = {
      prev = '<cmd>lprev<cr>',
      next = '<cmd>lnext<cr>',
      prev_desc = 'Prev location item',
      next_desc = 'Next location item',
    },
    L = {
      prev = '<cmd>lfirst<cr>',
      next = '<cmd>llast<cr>',
      prev_desc = 'First location item',
      next_desc = 'Last location item',
    },
    b = {
      prev = '<cmd>bprev<cr>',
      next = '<cmd>bnext<cr>',
      prev_desc = 'Prev buffer',
      next_desc = 'Next buffer',
    },
    B = {
      prev = '<cmd>bfirst<cr>',
      next = '<cmd>blast<cr>',
      prev_desc = 'First buffer',
      next_desc = 'Last buffer',
    },
    w = {
      prev = '<C-w>p',
      next = '<C-w>w',
      prev_desc = 'Previously focused window',
      next_desc = 'Next window',
    },
    j = {
      prev = '<C-o>',
      next = '<C-i>',
      prev_desc = 'Older jump',
      next_desc = 'Newer jump',
    },
    x = {
      prev = function()
        goto_conflict(false)
      end,
      next = function()
        goto_conflict(true)
      end,
      prev_desc = 'Prev merge conflict',
      next_desc = 'Next merge conflict',
    },
  },
}

for char, map in pairs(config.mappings) do
  if map then
    vim.keymap.set(
      'n',
      config.prev_prefix .. char,
      map.prev,
      { desc = map.prev_desc }
    )
    vim.keymap.set(
      'n',
      config.next_prefix .. char,
      map.next,
      { desc = map.next_desc }
    )
  end
end
