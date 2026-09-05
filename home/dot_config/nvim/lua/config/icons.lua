---@class icons
local M = {}

---@alias icons.Groups 'filetype'|'fs'|'git'|'kinds'|'lsp'|'ui'
---@alias icons.PaddingDirection 'left'|'right'|'both'

---@class icons.Lsp
---@overload fun(icon_name: string, padding_direction?: icons.PaddingDirection, padding_size?: integer): string
M.lsp = {
  error = '',
  warn = '',
  info = '󰋼',
  hint = '󰌶',
  trace = '',
  debug = '',
  other = '󰠠',
}

---@class icons.Git
---@overload fun(icon_name: string, padding_direction?: icons.PaddingDirection, padding_size?: integer): string
M.git = {
  add = '󰐕',
  branch = '',
  change = '∼',
  conflict = '',
  delete = '󰍴',
  logo = '󰊢',
  renamed = '',
  repository = '',
  untracked = '',
}

---@class icons.Fs
---@overload fun(icon_name: string, padding_direction?: icons.PaddingDirection, padding_size?: integer): string
M.fs = {
  file = '',
  files = '',
  folder = '',
  open_folder = '',
}

---@class icons.Filetype
---@overload fun(icon_name: string, padding_direction?: icons.PaddingDirection, padding_size?: integer): string
M.filetype = {
  bash = '',
  c = '',
  cpp = '',
  css = '',
  docker = '󰡨',
  git = '',
  go = '',
  help = '󰮥',
  html = '',
  java = '',
  javascript = '',
  json = '',
  lua = '',
  markdown = '',
  php = '',
  python = '',
  regex = '',
  ruby = '',
  rust = '',
  sql = '',
  toml = '',
  typescript = '',
  vim = '',
  yaml = '',
}

---@class icons.Ui
---@overload fun(icon_name: string, padding_direction?: icons.PaddingDirection, padding_size?: integer): string
M.ui = {
  up = '󰜷',
  down = '󰜮',
  left = '󰜱',
  right = '󰜴',

  anchor = '',
  bell = '',
  calendar = '',
  check = '󰄬',
  clock = '',
  close = '󰅖',
  comment = '',
  dot = '',
  small_dot = '',
  ellipsis = '',
  keyboard = '󰌌',
  lock = '󰌾',
  lsp = '',
  minus = '',
  plus = '',
  question = '',
  refresh = '',
  search = '',
  star = '',
  switch = '󰔡',
  telescope = '',
}

---@class icons.Kinds
---@overload fun(icon_name: string, padding_direction?: icons.PaddingDirection, padding_size?: integer): string
M.kinds = {
  Array = '',
  Boolean = '',
  Class = '',
  Color = '',
  Constant = '',
  Constructor = '',
  Enum = '',
  EnumMember = '',
  Event = '',
  Field = '',
  File = '',
  Folder = '',
  Function = '',
  Interface = '',
  Key = '',
  Keyword = '',
  Method = '',
  Module = '',
  Namespace = '',
  Null = '',
  Number = '',
  Object = '',
  Operator = '',
  Package = '',
  Property = '',
  Reference = '',
  Snippet = '󰘖',
  String = '',
  Struct = '',
  Text = '󰉿',
  TypeParameter = '',
  Unit = '',
  Value = '',
  Variable = '',
}

---@param icon_group icons.Groups
---@return {glyph: string}
function M.convert_to_mini(icon_group)
  local group = M[icon_group]
  local mini_group = {}
  for ft, glyph in pairs(group) do
    mini_group[ft:lower()] = { glyph = glyph }
  end
  return mini_group
end

---@param self table<string, string>
---@param icon_name string
---@param padding_direction? icons.PaddingDirection
---@param padding_size? integer
---@return string icon
local function get_icon(self, icon_name, padding_direction, padding_size)
  local icon = self[icon_name]

  if type(icon) ~= 'string' then return '' end
  if padding_direction == nil then return icon end

  local padding = string.rep(' ', padding_size or 1)

  local left = (padding_direction == 'left' or padding_direction == 'both')
      and padding
    or ''
  local right = (padding_direction == 'right' or padding_direction == 'both')
      and padding
    or ''

  return left .. icon .. right
end

local groups = { M.filetype, M.fs, M.git, M.kinds, M.lsp, M.ui }

---@cast groups table[]
for _, group in ipairs(groups) do
  setmetatable(group, { __call = get_icon })
end

return M
