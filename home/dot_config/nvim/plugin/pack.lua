local function gh(r)
  return 'https://github.com/' .. r
end

local function to_src(s)
  if s:match('^[%w._-]+/[%w._-]+$') then return gh(s) end
  return s
end

local function norm(spec)
  if type(spec) == 'string' then spec = { src = spec } end
  spec = vim.deepcopy(spec)
  spec.src = to_src(spec.src)
  spec.name = spec.name or spec.src:gsub('%.git$', ''):match('[^/]+$')
  local cfg, build = spec.config, spec.build
  spec.config, spec.build = nil, nil
  if build then
    spec.data = vim.tbl_extend('keep', spec.data or {}, { build = build })
  end
  return spec, cfg
end

local function add(specs, opts)
  if type(specs) == 'string' or specs.src then specs = { specs } end
  local out, cfgs = {}, {}
  for _, s in ipairs(specs) do
    local spec, cfg = norm(s)
    out[#out + 1] = spec
    if cfg then cfgs[#cfgs + 1] = { spec.name, cfg } end
  end
  vim.pack.add(out, opts)
  for _, c in ipairs(cfgs) do
    local ok, err = pcall(c[2])
    if not ok then
      vim.notify(
        ('pack: config %s failed\n%s'):format(c[1], err),
        vim.log.levels.ERROR
      )
    end
  end
end

local function plugs()
  return vim.pack.get(nil, { info = false })
end

local function orphans()
  return vim
    .iter(plugs())
    :filter(function(p)
      return not p.active
    end)
    :map(function(p)
      return p.spec.name
    end)
    :totable()
end

local function clean(opts)
  local names = orphans()
  if #names == 0 then return vim.notify('pack: nothing to clean') end
  local msg = 'Delete from disk?\n  ' .. table.concat(names, '\n  ')
  if (opts and opts.force) or vim.fn.confirm(msg, '&Yes\n&No', 2) == 1 then
    vim.pack.del(names)
  end
end

local function scratch(name, lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'
  pcall(vim.api.nvim_buf_set_name, buf, name)
  vim.cmd.split()
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_height(0, math.min(#lines + 1, 20))
  vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = buf })
end

local function ver(spec)
  local v = spec.version
  if v == nil then return 'default' end
  if type(v) == 'string' then return v end
  return ('%s - %s'):format(tostring(v.from), tostring(v.to))
end

local function list()
  local p = plugs()
  table.sort(p, function(a, b)
    return a.spec.name < b.spec.name
  end)
  local lines = {}
  for _, x in ipairs(p) do
    lines[#lines + 1] = ('%-28s %-8s %-14s %s'):format(
      x.spec.name,
      x.rev:sub(1, 7),
      ver(x.spec),
      x.active and '' or '(inactive)'
    )
  end
  scratch('pack://list', lines)
end

local function open(name)
  local p = vim.pack.get({ name }, { info = false })[1]
  if not p then
    return vim.notify(
      'pack: no plugin ' .. tostring(name),
      vim.log.levels.ERROR
    )
  end
  vim.cmd.tabedit(vim.fn.fnameescape(p.path))
end

local function log()
  vim.cmd.tabedit(
    vim.fn.fnameescape(vim.fs.joinpath(vim.fn.stdpath('log'), 'nvim-pack.log'))
  )
end

local function lock()
  vim.cmd.tabedit(
    vim.fn.fnameescape(
      vim.fs.joinpath(vim.fn.stdpath('config'), 'nvim-pack-lock.json')
    )
  )
end

local function names_or_nil(a)
  return #a > 0 and a or nil
end

local actions = {
  add = function(a)
    if #a == 0 then
      return vim.notify('usage: :Pack add {src}', vim.log.levels.ERROR)
    end
    add(a)
    vim.notify(
      'pack: added ' .. table.concat(a, ', ') .. '\nAdd to init.lua to persist.'
    )
  end,
  update = function(a, bang)
    vim.pack.update(names_or_nil(a), { force = bang })
  end,
  review = function(a)
    vim.pack.update(names_or_nil(a), { offline = true })
  end,
  restore = function(a, bang)
    vim.pack.update(
      names_or_nil(a),
      { offline = true, target = 'lockfile', force = bang }
    )
  end,
  del = function(a, bang)
    if #a == 0 then
      return vim.notify('usage: :Pack del {name}', vim.log.levels.ERROR)
    end
    vim.pack.del(a, { force = bang })
  end,
  list = function()
    list()
  end,
  clean = function(_, bang)
    clean({ force = bang })
  end,
  open = function(a)
    open(a[1])
  end,
  log = function()
    log()
  end,
  lock = function()
    lock()
  end,
}

local takes_names = {
  update = true,
  review = true,
  restore = true,
  del = true,
  open = true,
}

local function complete(arglead, cmdline)
  local parts = vim.split(cmdline, '%s+', { trimempty = true })
  local idx = #parts + (arglead == '' and 1 or 0)
  local pool
  if idx <= 2 then
    pool = vim.tbl_keys(actions)
  elseif takes_names[parts[2]] then
    pool = vim.tbl_map(function(p)
      return p.spec.name
    end, plugs())
  else
    return {}
  end
  table.sort(pool)
  return vim.tbl_filter(function(x)
    return vim.startswith(x, arglead)
  end, pool)
end

vim.api.nvim_create_user_command('Pack', function(a)
  local args = vim.list_slice(a.fargs)
  local sub = table.remove(args, 1) or 'list'
  local fn = actions[sub]
  if not fn then
    return vim.notify('pack: unknown action ' .. sub, vim.log.levels.ERROR)
  end
  fn(args, a.bang)
end, {
  nargs = '*',
  bang = true,
  complete = complete,
  desc = 'vim.pack: add/update/del/list/clean/...',
})
