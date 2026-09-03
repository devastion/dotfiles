---@type vim.lsp.Config
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
    '.git',
  },
  on_init = function(client)
    local completion = client.server_capabilities
      and client.server_capabilities.completionProvider
    if completion then completion.triggerCharacters = { '.', ':', '#', '(' } end

    if not client.workspace_folders then return end

    local root = client.workspace_folders[1].name
    local nvim_config = vim.fn.stdpath('config')

    if root ~= nvim_config then
      if
        vim.uv.fs_stat(root .. '/.luarc.json')
        or vim.uv.fs_stat(root .. '/.luarc.jsonc')
      then
        return
      end
    end

    client.config.settings.Lua.workspace.library = {
      vim.env.VIMRUNTIME,
      '${3rd}/luv/library',
    }
  end,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = { '?.lua', '?/init.lua' },
      },

      workspace = {
        ignoreSubmodules = true,
        checkThirdParty = false,
      },

      diagnostics = {
        globals = { 'vim' },
        unusedLocalExclude = { '_*' },
        -- disable = { 'missing-fields' },
      },

      completion = {
        callSnippet = 'Both',
        keywordSnippet = 'Both',
        showWord = 'Fallback',
        postfix = '@',
        autoRequire = true,
      },

      hint = {
        enable = true,
        setType = true,
        paramName = 'All',
        paramType = true,
        arrayIndex = 'Enable',
        await = true,
        semicolon = 'Disable',
      },

      type = {
        castNumberToInteger = true,
        inferParamType = true,
      },

      doc = {
        privateName = { '_*' },
      },

      codeLens = { enable = true },

      hover = {
        expandAlias = true,
        viewNumber = true,
        viewString = true,
      },

      format = { enable = false },

      semantic = {
        enable = true,
        annotation = true,
      },
    },
  },
}
