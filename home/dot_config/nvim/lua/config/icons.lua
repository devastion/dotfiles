local M = {}

M.lsp = {
  error = '',
  warn = '',
  info = '󰋼',
  hint = '󰌶',
  trace = '',
  debug = '',
  other = '󰠠',
}

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

M.fs = {
  file = '',
  files = '',
  folder = '',
  open_folder = '',
}

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

for _, group in ipairs({ M.filetype, M.fs, M.git, M.kinds, M.lsp, M.ui }) do
  setmetatable(group, {
    ---@param self table<string, string>
    ---@param icon_name string
    ---@param padding_direction? 'left'|'right'|'both'
    ---@param padding_size? integer
    ---@return string
    __call = function(self, icon_name, padding_direction, padding_size)
      local icon = self[icon_name]

      if type(icon) ~= 'string' then return '' end
      if padding_direction == nil then return icon end

      local padding = string.rep(' ', padding_size or 1)

      local left = (padding_direction == 'left' or padding_direction == 'both')
          and padding
        or ''
      local right = (
        padding_direction == 'right' or padding_direction == 'both'
      )
          and padding
        or ''

      return left .. icon .. right
    end,
  })
end

return M
