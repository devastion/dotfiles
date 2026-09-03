local api = vim.api

---@type integer?
local win_id = nil

---@type integer?
local buf_id = nil

---@type { row: integer, col_offset: integer }
local config = {
  row = 2,
  col_offset = 4,
}

---@return nil
local function close_banner()
  if win_id and api.nvim_win_is_valid(win_id) then
    api.nvim_win_close(win_id, true)
  end

  if buf_id and api.nvim_buf_is_valid(buf_id) then
    api.nvim_buf_delete(buf_id, { force = true })
  end

  win_id = nil
  buf_id = nil
end

---@return nil
local function open_banner()
  local reg = vim.fn.reg_recording()

  if reg == '' then return end

  close_banner()

  local text = string.format(' ● REC @%s ', reg)
  local width = vim.fn.strdisplaywidth(text)

  buf_id = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf_id, 0, -1, false, { text })

  local col = vim.o.columns - width - config.col_offset

  win_id = api.nvim_open_win(buf_id, false, {
    relative = 'editor',
    width = width,
    height = 1,
    row = config.row,
    col = col,
    style = 'minimal',
    border = 'none',
    focusable = false,
    zindex = 150,
  })

  api.nvim_set_option_value(
    'winhighlight',
    'Normal:DiagnosticError',
    { win = win_id }
  )
end

local group =
  api.nvim_create_augroup('user.macro.recording_banner', { clear = true })

api.nvim_create_autocmd('RecordingEnter', {
  group = group,
  desc = 'Show a banner while recording a macro',
  callback = open_banner,
})

api.nvim_create_autocmd('RecordingLeave', {
  group = group,
  desc = 'Hide the recording banner shortly after recording stops',
  callback = function()
    vim.defer_fn(function()
      if vim.fn.reg_recording() == '' then close_banner() end
    end, 50)
  end,
})

api.nvim_create_autocmd('VimResized', {
  group = group,
  desc = 'Reposition the recording banner after a resize',
  callback = function()
    if win_id and api.nvim_win_is_valid(win_id) then open_banner() end
  end,
})

api.nvim_create_autocmd('TabEnter', {
  group = group,
  desc = 'Follow the recording banner across tabs',
  callback = function()
    if vim.fn.reg_recording() ~= '' then open_banner() end
  end,
})
