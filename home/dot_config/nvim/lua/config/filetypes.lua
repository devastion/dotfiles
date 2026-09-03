vim.filetype.add({
  extension = {
    mdx = 'markdown.mdx',
    http = 'http',
    tsv = 'tsv',
    conf = function(path)
      if path:match('/gnupg/') then return 'gpg' end
      return 'conf'
    end,
    dircolors = 'dircolors',
  },
  filename = {
    ['.zshenv'] = 'zsh',
    ['.zshrc'] = 'zsh',
    ['.zprofile'] = 'zsh',
    ['.zlogin'] = 'zsh',
    ['.bashrc'] = 'bash',
    ['.bash_profile'] = 'bash',

    ['Brewfile'] = 'ruby',
    ['Dockerfile'] = 'dockerfile',
    ['Gemfile'] = 'ruby',
    ['Rakefile'] = 'ruby',
    ['Makefile'] = 'make',
    ['.editorconfig'] = 'editorconfig',
    ['tmux.conf'] = 'tmux',

    ['config'] = function(path)
      if path:match('/%.ssh/') then
        return 'sshconfig'
      elseif path:match('/ghostty/') then
        return 'ghostty'
      elseif path:match('/git/') then
        return 'gitconfig'
      end

      return 'conf'
    end,
  },
  pattern = {
    ['.*compose.*%.ya?ml'] = 'yaml.docker-compose',
    ['.*/zsh/.*'] = function(path)
      local name = vim.fs.basename(path)
      if not name:find('%.', 2) then return 'zsh' end
    end,
    ['%.env%.[%w_.]+'] = 'sh',
    ['%.env%.local'] = 'sh',
    ['[jt]sconfig.*%.json$'] = 'jsonc',
    ['.*/%.github/workflows/.*%.ya?ml'] = 'yaml.github',
    ['.*/Cargo%.lock$'] = 'toml',
    ['%./pyproject%.toml$'] = 'toml',
  },
})
