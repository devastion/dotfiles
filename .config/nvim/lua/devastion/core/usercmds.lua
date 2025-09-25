local usercmd = vim.api.nvim_create_user_command

usercmd("RestoreTabPagesName", function()
  local tabs = vim.api.nvim_list_tabpages()

  for i, _t in ipairs(tabs) do
    local custom_name = vim.g["TabPageCustomName" .. i]
    if custom_name and custom_name ~= "" then
      vim.api.nvim_tabpage_set_var(i, "name", custom_name)
    end
  end
end, {
  desc = "Restore Tab Pages Name",
})

usercmd("VimPack", function(args)
  local fargs = args.fargs
  local subcommand_key = fargs[1]

  local subcommand_tbl = {
    clean = function()
      local active_plugins = {
        "render-markdown.nvim",
        "markdown-preview.nvim",
        "scope.nvim",
        "bufferline.nvim",
      }
      local unused_plugins = {}

      for _, plugin in ipairs(vim.pack.get()) do
        active_plugins[plugin.spec.name] = plugin.active
      end

      for _, plugin in ipairs(vim.pack.get()) do
        if not active_plugins[plugin.spec.name] then
          table.insert(unused_plugins, plugin.spec.name)
        end
      end

      if #unused_plugins == 0 then
        print("No unused plugins.")
        return
      end

      local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
      if choice == 1 then
        vim.pack.del(unused_plugins)
      end
    end,
    update = vim.pack.update,
  }

  local subcommand = subcommand_tbl[subcommand_key]

  if not subcommand then
    vim.notify("VimPack: Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
  end

  subcommand()
end, {
  nargs = "+",
  desc = "vim.pack commands",
  complete = function(arg_lead, cmdline, _)
    if cmdline:match("^['<,'>]*VimPack[!]*%s+%w*$") then
      local subcommand_keys = { "clean", "update" }
      return vim.iter(subcommand_keys):filter(function(key) return key:find(arg_lead) ~= nil end):totable()
    end
  end,
})
