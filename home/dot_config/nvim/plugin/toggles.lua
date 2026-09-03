---@alias TogglesScope 'o' | 'wo' | 'bo' | 'g' | 'b'

---@type table<TogglesScope, string>
local scope_names = {
  o = 'global option',
  wo = 'window option',
  bo = 'buffer option',
  g = 'global variable',
  b = 'buffer variable',
}

local config = {
  prefix = '<leader>u',
}

---@param name string
---@param scope? TogglesScope defaults to `wo`
---@return function
local function toggle_option(name, scope)
  scope = scope or 'wo'
  return function()
    vim[scope][name] = not vim[scope][name]
    vim.notify(
      ('%s %s (%s)'):format(
        vim[scope][name] and 'Enabled' or 'Disabled',
        name,
        scope_names[scope]
      ),
      vim.log.levels.INFO,
      { title = 'Toggle' }
    )
  end
end

local function toggle_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  local enabled = vim.diagnostic.is_enabled({ bufnr = bufnr })
  vim.diagnostic.enable(not enabled, { bufnr = bufnr })
  vim.notify(
    (enabled and 'Disabled' or 'Enabled') .. ' diagnostics',
    vim.log.levels.INFO,
    { title = 'Toggle' }
  )
end

---@param name string
---@return function
local function toggle_buffer_override(name)
  return function()
    local disabled = vim.b[name] == false
    if disabled then
      vim.b[name] = nil
    else
      vim.b[name] = false
    end
    vim.notify(
      ('%s %s (%s)'):format(
        disabled and 'Enabled' or 'Disabled',
        name,
        scope_names.b
      ),
      vim.log.levels.INFO,
      { title = 'Toggle' }
    )
  end
end

local function toggle_quickfix()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd.cclose()
  else
    vim.cmd.copen()
  end
end

---@type table<string, { fn: function, desc: string }>
local mappings = {
  c = { fn = toggle_option('cursorline'), desc = 'cursorline' },
  d = { fn = toggle_diagnostics, desc = 'diagnostics (buffer)' },
  h = { fn = toggle_option('cursorcolumn'), desc = 'cursorcolumn' },
  n = { fn = toggle_option('number'), desc = 'number' },
  q = { fn = toggle_quickfix, desc = 'quickfix list' },
  r = { fn = toggle_option('relativenumber'), desc = 'relativenumber' },
  s = { fn = toggle_option('spell'), desc = 'spell' },
  w = { fn = toggle_option('wrap'), desc = 'wrap' },
  F = {
    fn = toggle_buffer_override('autoformat'),
    desc = 'autoformat (buffer)',
  },
  L = { fn = toggle_buffer_override('autolint'), desc = 'autolint (buffer)' },
  g = {
    desc = 'git signs',
    fn = function()
      require('gitsigns').toggle_signs()
    end,
  },
  f = {
    desc = 'format on save',
    fn = function()
      vim.g.autoformat = not vim.g.autoformat
      vim.b.autoformat = nil
    end,
  },
  l = {
    desc = 'lint on write',
    fn = function()
      vim.g.autolint = not vim.g.autolint
      vim.b.autolint = nil
    end,
  },
  i = {
    desc = 'inlay hints',
    fn = function()
      vim.lsp.inlay_hint.enable(
        not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }),
        { bufnr = 0 }
      )
    end,
  },
  I = {
    desc = 'indent guides',
    fn = function()
      vim.b.miniindentscope_disable = not vim.b.miniindentscope_disable
    end,
  },
  t = {
    desc = 'treesitter highlighting',
    fn = function()
      local buf = vim.api.nvim_get_current_buf()
      if vim.treesitter.highlighter.active[buf] then
        pcall(vim.treesitter.stop, buf)
      else
        pcall(vim.treesitter.start, buf)
      end
    end,
  },
  v = {
    desc = 'diagnostic virtual lines',
    fn = function()
      local lines = vim.diagnostic.config().virtual_lines and true or false
      vim.diagnostic.config({
        virtual_lines = not lines and { current_line = true } or false,
        virtual_text = lines and {
          severity = { min = vim.diagnostic.severity.WARN },
        } or false,
      })
    end,
  },
}

for char, map in pairs(mappings) do
  if map then
    vim.keymap.set(
      'n',
      config.prefix .. char,
      map.fn,
      { desc = 'Toggle ' .. map.desc }
    )
  end
end
