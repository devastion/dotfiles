local icons = require('config.icons')

local M = {}

local did_setup = false

function M.setup()
  if did_setup then return end
  vim.pack.add({
    'https://github.com/mason-org/mason.nvim',
  }, { confirm = false })

  require('mason').setup({
    registries = {
      'github:devastion/mason-registry',
      'github:mason-org/mason-registry',
    },
    max_concurrent_installers = 8,
    ui = {
      check_outdated_packages_on_open = true,
      icons = {
        package_installed = icons.ui.check,
        package_pending = icons.ui.right,
        package_uninstalled = icons.ui.close,
      },
      width = 0.8,
      height = 0.8,
    },
  })

  vim.keymap.set(
    'n',
    '<leader>cm',
    '<cmd>Mason<cr>',
    { desc = 'Mason', silent = true }
  )
  did_setup = true
end

---Extract all unique strings from a nested table structure
---@param ... table[]
---@return string[]
local function unique(...)
  local tbl = vim.tbl_extend('keep', {}, ...)
  local out = {}
  local seen = {}

  local function walk(t)
    for _, v in pairs(t) do
      if type(v) == 'string' then
        if not seen[v] then
          seen[v] = true
          table.insert(out, v)
        end
      elseif type(v) == 'table' then
        walk(v)
      elseif type(v) == 'function' then
        walk(v())
      end
    end
  end

  walk(tbl)

  return out
end

---Try to resolve a mason package with fallback name transformations.
---Example: `json_repair` -> `json-repair`
---@param name string
---@param registry RegistrySource
---@return boolean resolved
---@return Package? resolved_package
local function resolve_package(name, registry)
  local resolved, resolved_package = pcall(registry.get_package, name)
  if resolved then return true, resolved_package end

  local alt_name = name:gsub('_', '-')
  resolved, resolved_package = pcall(registry.get_package, alt_name)
  if resolved then return true, resolved_package end

  return false, nil
end

---@type table<string, true>
local pending = {}
local flush_scheduled = false

local function flush()
  flush_scheduled = false

  local packages = vim.tbl_keys(pending)
  pending = {}
  if #packages == 0 then return end
  table.sort(packages)

  local ok, registry = pcall(require, 'mason-registry')
  if not ok then
    vim.notify(
      ('Module %s not found\n\n%s'):format('mason-registry', registry),
      vim.log.levels.ERROR,
      { title = 'Mason' }
    )
    return
  end

  ---@type string[]
  local missing = {}
  for _, name in ipairs(packages) do
    local resolved, resolved_package = resolve_package(name, registry)
    if
      not resolved
      or (resolved_package and not resolved_package:is_installed())
    then
      missing[#missing + 1] = name
    end
  end

  if #missing == 0 then return end

  registry.refresh(function()
    for _, name in ipairs(missing) do
      local resolved, resolved_package = resolve_package(name, registry)

      if not resolved then
        vim.notify(
          ('Package %s not found'):format(name),
          vim.log.levels.ERROR,
          { title = 'Mason' }
        )
      elseif resolved_package and not resolved_package:is_installed() then
        vim.notify(
          ('Installing %s'):format(name),
          vim.log.levels.INFO,
          { title = 'Mason' }
        )
        resolved_package:install()
      end
    end
  end)
end

local function schedule_flush()
  if flush_scheduled then return end
  flush_scheduled = true

  if vim.v.vim_did_enter == 1 then
    vim.schedule(flush)
  else
    vim.api.nvim_create_autocmd('VimEnter', {
      group = vim.api.nvim_create_augroup('devastion.mason', { clear = true }),
      once = true,
      desc = 'Resolve requested Mason packages',
      callback = vim.schedule_wrap(flush),
    })
  end
end

---@param ... table<string,any>
function M.install(...)
  M.setup()

  for _, name in ipairs(unique(...)) do
    pending[name] = true
  end

  schedule_flush()
end

return M
