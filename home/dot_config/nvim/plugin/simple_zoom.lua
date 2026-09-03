local config = {
  ---@type table?
  win_config = nil,
}

---@type integer?
local zoom_winid = nil

---@param text string
---@param width integer
---@return string
local function fit_to_width(text, width)
  local len = vim.fn.strchars(text)
  return len <= width and text
    or ('…' .. vim.fn.strcharpart(text, len - width + 1, width - 1))
end

---@return vim.api.keyset.win_config
local function compute_win_config()
  local max_width, max_height = vim.o.columns, vim.o.lines - vim.o.cmdheight
  local default_border = vim.o.winborder == '' and 'none' or nil
  local default_config = {
    relative = 'editor',
    row = 0,
    col = 0,
    width = max_width,
    height = max_height,
    title = ' Zoom ',
    border = default_border,
  }
  local res =
    vim.tbl_deep_extend('force', default_config, config.win_config or {})
  local bor = res.border == 'none' and { '' } or res.border
  local n = type(bor) == 'table' and #bor or 0
  local height_offset = n == 0 and 2
    or ((bor[1 % n + 1] == '' and 0 or 1) + (bor[5 % n + 1] == '' and 0 or 1))
  local width_offset = n == 0 and 2
    or ((bor[3 % n + 1] == '' and 0 or 1) + (bor[7 % n + 1] == '' and 0 or 1))
  res.height = math.min(res.height, max_height - height_offset)
  res.width = math.min(res.width, max_width - width_offset)

  if type(res.title) == 'string' then
    res.title = fit_to_width(res.title, res.width)
  end

  return res
end

local function zoom_out()
  if not (zoom_winid and vim.api.nvim_win_is_valid(zoom_winid)) then return end
  pcall(vim.api.nvim_del_augroup_by_name, 'devastion.zoom')
  vim.api.nvim_win_close(zoom_winid, true)
  zoom_winid = nil
end

local function zoom_in()
  zoom_winid = vim.api.nvim_open_win(0, true, compute_win_config())
  vim.wo[zoom_winid].winblend = 0
  vim.cmd('normal! zz')

  local group = vim.api.nvim_create_augroup('devastion.zoom', { clear = true })
  local function adjust_config()
    if not (zoom_winid and vim.api.nvim_win_is_valid(zoom_winid)) then
      pcall(vim.api.nvim_del_augroup_by_name, 'devastion.zoom')
      return
    end
    vim.api.nvim_win_set_config(zoom_winid, compute_win_config())
  end
  vim.api.nvim_create_autocmd(
    'VimResized',
    { group = group, callback = adjust_config }
  )
  vim.api.nvim_create_autocmd(
    'OptionSet',
    { group = group, pattern = 'cmdheight', callback = adjust_config }
  )
end

local function toggle_zoom()
  if zoom_winid and vim.api.nvim_win_is_valid(zoom_winid) then
    zoom_out()
  else
    zoom_in()
  end
end

vim.api.nvim_create_user_command(
  'SimpleZoomToggle',
  toggle_zoom,
  { desc = 'Toggle Simple Zoom on and off' }
)
vim.keymap.set('n', '<leader>z', toggle_zoom, { desc = 'Toggle zoom' })
