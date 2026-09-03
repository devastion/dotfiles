local M = {}

---@alias StatusColumnComponent 'mark'|'sign'|'fold'|'git'

local config = {
  set_option = true,
  ---@type StatusColumnComponent[]|fun(win: integer, buf: integer, lnum: integer): StatusColumnComponent[]
  left = { 'mark', 'sign' },
  ---@type StatusColumnComponent[]|fun(win: integer, buf: integer, lnum: integer): StatusColumnComponent[]
  right = { 'fold', 'git' },
  folds = {
    open = false,
    git_hl = false,
  },
  git = {
    patterns = { 'GitSign', 'MiniDiffSign' },
  },
}

---@class StatusColumnSign
---@field text? string
---@field texthl? string
---@field priority? number
---@field type StatusColumnComponent

---@type table<string, table<integer, StatusColumnSign[]>>
local sign_cache = {}

---@type table<string, string>
local line_cache = {}

---@type table<string, string>
local icon_cache = {}

---@param name string
---@return boolean
local function is_git_sign(name)
  for _, pattern in ipairs(config.git.patterns) do
    if name:find(pattern) then return true end
  end
  return false
end

---@param buf integer
---@param wanted table<string, boolean>
---@return table<integer, StatusColumnSign[]>
local function buf_signs(buf, wanted)
  local signs = {}

  if wanted.sign or wanted.git then
    for _, extmark in
      ipairs(
        vim.api.nvim_buf_get_extmarks(
          buf,
          -1,
          0,
          -1,
          { details = true, type = 'sign' }
        )
      )
    do
      local details = extmark[4]
      local name = details.sign_hl_group or details.sign_name or ''
      local kind = is_git_sign(name) and 'git' or 'sign'

      if wanted[kind] then
        local lnum = extmark[2] + 1
        signs[lnum] = signs[lnum] or {}
        table.insert(signs[lnum], {
          text = details.sign_text,
          texthl = details.sign_hl_group,
          priority = details.priority,
          type = kind,
        })
      end
    end
  end

  if wanted.mark then
    local marks = vim.fn.getmarklist(buf)
    vim.list_extend(marks, vim.fn.getmarklist())

    for _, mark in ipairs(marks) do
      if mark.pos[1] == buf and mark.mark:match('[a-zA-Z]') then
        local lnum = mark.pos[2]
        signs[lnum] = signs[lnum] or {}
        table.insert(signs[lnum], {
          text = mark.mark:sub(2),
          texthl = 'StatusColumnMark',
          type = 'mark',
        })
      end
    end
  end

  return signs
end

---@param win integer
---@param lnum integer
---@return StatusColumnSign?
local function fold_sign(win, lnum)
  local ok, fold = pcall(vim.api.nvim_win_call, win, function()
    return {
      closed = vim.fn.foldclosed(lnum) == lnum,
      starts = vim.fn.foldlevel(lnum) > vim.fn.foldlevel(lnum - 1),
    }
  end)
  if not ok then return nil end

  local fillchars = vim.opt.fillchars:get()
  if fold.closed then
    return {
      text = fillchars.foldclose or '+',
      texthl = 'Folded',
      type = 'fold',
    }
  elseif config.folds.open and fold.starts then
    return { text = fillchars.foldopen or '-', type = 'fold' }
  end
end

---@param win integer
---@param buf integer
---@param lnum integer
---@param wanted table<string, boolean>
---@param wanted_key string
---@return StatusColumnSign[]
local function line_signs(win, buf, lnum, wanted, wanted_key)
  local cache_key = buf .. ':' .. wanted_key
  if not sign_cache[cache_key] then
    sign_cache[cache_key] = buf_signs(buf, wanted)
  end

  local signs = vim.list_extend({}, sign_cache[cache_key][lnum] or {})
  if wanted.fold then
    local fold = fold_sign(win, lnum)
    if fold then signs[#signs + 1] = fold end
  end

  table.sort(signs, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
  end)
  return signs
end

---@param sign? StatusColumnSign
---@return string
local function icon(sign)
  if not sign then return '  ' end

  local key = (sign.text or '') .. '\0' .. (sign.texthl or '')
  if icon_cache[key] then return icon_cache[key] end

  local text = vim.fn.strcharpart(sign.text or '', 0, 2)
  text = text .. string.rep(' ', 2 - vim.fn.strchars(text))
  icon_cache[key] = sign.texthl and ('%#' .. sign.texthl .. '#' .. text .. '%*')
    or text
  return icon_cache[key]
end

---@param components StatusColumnComponent[]|fun(...): StatusColumnComponent[]
---@param win integer
---@param buf integer
---@param lnum integer
---@return StatusColumnComponent[]
local function resolve(components, win, buf, lnum)
  return type(components) == 'function' and components(win, buf, lnum)
    or components
end

---@return string
local function build()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)

  local number = vim.wo[win].number
  local relative = vim.wo[win].relativenumber
  -- Virtual and wrapped lines get the column's width but none of its content.
  local real_line = vim.v.virtnum == 0
  local show_signs = real_line and vim.wo[win].signcolumn ~= 'no'
  local show_folds = real_line and vim.wo[win].foldcolumn ~= '0'

  if not (show_signs or show_folds or number or relative) then return '' end

  local left_of = resolve(config.left, win, buf, vim.v.lnum)
  local right_of = resolve(config.right, win, buf, vim.v.lnum)

  local wanted = { sign = show_signs, fold = show_folds }
  for _, list in ipairs({ left_of, right_of }) do
    for _, component in ipairs(list) do
      if wanted[component] == nil then wanted[component] = true end
    end
  end

  local kinds = {}
  for _, kind in ipairs({ 'mark', 'sign', 'fold', 'git' }) do
    if wanted[kind] then kinds[#kinds + 1] = kind end
  end
  local wanted_key = table.concat(kinds, ',')

  local left, middle, right = '', '', ''

  if (number or relative) and real_line then
    local lnum = vim.v.lnum
    if relative and not (number and vim.v.relnum == 0) then
      lnum = vim.v.relnum
    end
    middle = '%=' .. lnum .. ' '
  end

  if show_signs or show_folds then
    local signs = line_signs(win, buf, vim.v.lnum, wanted, wanted_key)

    ---First sign of each kind, which is the highest priority one after sorting.
    local by_type = {}
    for _, sign in ipairs(signs) do
      by_type[sign.type] = by_type[sign.type] or sign
    end

    ---@param components StatusColumnComponent[]
    ---@return StatusColumnSign?
    local function pick(components)
      for _, component in ipairs(components) do
        if by_type[component] then return by_type[component] end
      end
    end

    local left_sign, right_sign = pick(left_of), pick(right_of)

    if config.folds.git_hl and by_type.git then
      for _, sign in ipairs({ left_sign, right_sign }) do
        if sign and sign.type == 'fold' then
          sign.texthl = by_type.git.texthl
        end
      end
    end

    left, right = icon(left_sign), icon(right_sign)
  end

  if vim.b[buf].statuscolumn_left == false then left = '' end
  if vim.b[buf].statuscolumn_right == false then right = '' end

  return '%@v:lua.StatusColumn.click_fold@' .. left .. middle .. right .. '%T'
end

---@return string
function M.get()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  local key = ('%d:%d:%d:%d:%d'):format(
    win,
    buf,
    vim.v.lnum,
    vim.v.virtnum,
    vim.v.relnum
  )
  if line_cache[key] then return line_cache[key] end

  local ok, column = pcall(build)
  if not ok then return '' end

  line_cache[key] = column
  return column
end

function M.click_fold()
  local pos = vim.fn.getmousepos()
  if pos.winid == 0 then return end

  vim.api.nvim_win_call(pos.winid, function()
    if vim.fn.foldlevel(pos.line) == 0 then return end
    vim.api.nvim_win_set_cursor(pos.winid, { pos.line, 0 })
    vim.cmd.normal({ 'za', bang = true })
  end)
end

local function set_highlight()
  vim.api.nvim_set_hl(
    0,
    'StatusColumnMark',
    { link = 'DiagnosticHint', default = true }
  )
end
set_highlight()

local group =
  vim.api.nvim_create_augroup('devastion.statuscolumn', { clear = true })

vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  desc = 'Re-link the statuscolumn mark highlight',
  callback = set_highlight,
})

vim.api.nvim_create_autocmd({
  'BufEnter',
  'BufWritePost',
  'CursorHold',
  'DiagnosticChanged',
  'InsertLeave',
  'TextChanged',
  'TextChangedI',
  'WinScrolled',
}, {
  group = group,
  desc = 'Invalidate the statuscolumn caches',
  callback = function()
    sign_cache, line_cache = {}, {}
  end,
})

vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = { 'GitSignsUpdate', 'MiniDiffUpdated' },
  desc = 'Invalidate the statuscolumn caches after a git sign refresh',
  callback = function()
    sign_cache, line_cache = {}, {}
  end,
})

-- selene: allow(global_usage)
_G.StatusColumn = M
if config.set_option then vim.o.statuscolumn = '%!v:lua.StatusColumn.get()' end
