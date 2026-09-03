---@class CopyUrlInfo
---@field repo_url string
---@field ref string
---@field path string
---@field start_line integer
---@field end_line integer

local config = {
  register = '+',
  remote = 'origin',
  ---@type nil|fun(info: CopyUrlInfo): string
  url_format = nil,
  keys = {
    absolute_path = '<leader>ya',
    absolute_path_with_line = '<leader>yA',
    file_name = '<leader>yn',
    git_url = '<leader>yg',
    relative_path = '<leader>yr',
    relative_path_with_line = '<leader>yR',
  },
}

---@param content string?
local function copy(content)
  if content == nil or content == '' then
    vim.notify('Nothing to copy', vim.log.levels.WARN)
    return
  end
  vim.fn.setreg(config.register, content)
  vim.notify('Copied "' .. content .. '"', vim.log.levels.INFO)
end

---@return string? path
local function buf_path()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    vim.notify('Current buffer has no file path', vim.log.levels.WARN)
    return nil
  end
  return path
end

---@return string?
local function rel_path()
  local path = buf_path()
  if not path then return nil end
  return vim.fs.relpath(vim.uv.cwd() or '.', path) or path
end

local function cursor_line()
  return vim.api.nvim_win_get_cursor(0)[1]
end

---@param path string
---@return string
local function encode_path(path)
  return (
    path:gsub('[^%w%-%._~/]', function(char)
      return string.format('%%%02X', string.byte(char))
    end)
  )
end

---@param info CopyUrlInfo
---@return string
local function default_url_format(info)
  local segment = info.repo_url:match('bitbucket%.org') and 'src' or 'blob'
  local url = string.format(
    '%s/%s/%s/%s#L%d',
    info.repo_url,
    segment,
    info.ref,
    info.path,
    info.start_line
  )
  if info.end_line > info.start_line then url = url .. '-L' .. info.end_line end
  return url
end

---@param url string
---@return string
local function normalize_remote(url)
  url = url:gsub('%.git$', '')
  url = url:gsub('^ssh://git@', 'https://')
  url = url:gsub('^git@([^:/]+):', 'https://%1/')
  return url
end

---@param args string[]
---@param cwd string
---@param on_done fun(stdout?: string)
local function git(args, cwd, on_done)
  local cmd = vim.list_extend({ 'git', '-C', cwd }, args)
  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      on_done(result.code == 0 and vim.trim(result.stdout or '') or nil)
    end)
  end)
end

---@param start_line integer
---@param end_line integer
local function copy_git_url(start_line, end_line)
  local file = buf_path()
  if not file then return end
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local dir = vim.fs.dirname(file)

  git(
    {
      'rev-parse',
      '--show-toplevel',
      '--abbrev-ref',
      'HEAD',
      '--short',
      'HEAD',
    },
    dir,
    function(out)
      if not out then
        vim.notify('Not a git repository', vim.log.levels.WARN)
        return
      end
      local root, branch, sha = unpack(vim.split(out, '\n', { plain = true }))
      if not root or root == '' then
        vim.notify(
          'Could not determine the repository root',
          vim.log.levels.WARN
        )
        return
      end

      local path = vim.fs.relpath(root, file)
      if not path then
        vim.notify(
          'File is outside the repository at ' .. root,
          vim.log.levels.WARN
        )
        return
      end

      git(
        { 'config', '--get', 'remote.' .. config.remote .. '.url' },
        dir,
        function(origin)
          if not origin or origin == '' then
            vim.notify(
              ('No "%s" remote configured'):format(config.remote),
              vim.log.levels.WARN
            )
            return
          end

          local format = config.url_format or default_url_format
          copy(format({
            repo_url = normalize_remote(origin),
            ref = (branch ~= nil and branch ~= '' and branch ~= 'HEAD')
                and branch
              or sha,
            path = encode_path((path:gsub('\\', '/'))),
            start_line = start_line,
            end_line = end_line,
          }))
        end
      )
    end
  )
end

---Line range of the current visual selection, without leaving visual mode.
---@return integer start_line, integer end_line
local function visual_range()
  local a, b = vim.fn.line('v'), vim.fn.line('.')
  return math.min(a, b), math.max(a, b)
end

vim.api.nvim_create_user_command('CopyRelativePath', function()
  copy(rel_path())
end, { desc = 'Copy path relative to cwd' })

vim.api.nvim_create_user_command('CopyAbsolutePath', function()
  copy(buf_path())
end, { desc = 'Copy absolute path' })

vim.api.nvim_create_user_command('CopyRelativePathWithLine', function()
  local path = rel_path()
  if path then copy(path .. ':' .. cursor_line()) end
end, { desc = 'Copy path relative to cwd, with line number' })

vim.api.nvim_create_user_command('CopyAbsolutePathWithLine', function()
  local path = buf_path()
  if path then copy(path .. ':' .. cursor_line()) end
end, { desc = 'Copy absolute path, with line number' })

vim.api.nvim_create_user_command('CopyFileName', function()
  local path = buf_path()
  if path then copy(vim.fs.basename(path)) end
end, { desc = 'Copy file name' })

vim.api.nvim_create_user_command('CopyGitUrl', function(args)
  copy_git_url(args.line1, args.line2)
end, { range = true, desc = 'Copy a forge permalink to the current line(s)' })

local function map(mode, lhs, rhs, desc)
  if lhs then vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc }) end
end

map(
  'n',
  config.keys.relative_path,
  '<cmd>CopyRelativePath<cr>',
  'Copy relative path'
)
map(
  'n',
  config.keys.absolute_path,
  '<cmd>CopyAbsolutePath<cr>',
  'Copy absolute path'
)
map(
  'n',
  config.keys.relative_path_with_line,
  '<cmd>CopyRelativePathWithLine<cr>',
  'Copy relative path with line'
)
map(
  'n',
  config.keys.absolute_path_with_line,
  '<cmd>CopyAbsolutePathWithLine<cr>',
  'Copy absolute path with line'
)
map('n', config.keys.file_name, '<cmd>CopyFileName<cr>', 'Copy file name')
map('n', config.keys.git_url, function()
  copy_git_url(cursor_line(), cursor_line())
end, 'Copy git url')
map('x', config.keys.git_url, function()
  copy_git_url(visual_range())
end, 'Copy git url for selection')
