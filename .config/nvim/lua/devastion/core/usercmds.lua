local usercmd = vim.api.nvim_create_user_command

usercmd("ToggleLspClient", function()
  local lsp_configs = Devastion.lsp.get_lsp_configs()

  vim.ui.select(lsp_configs, {
    prompt = "Select LSP Client:",
  }, function(choice)
    if choice then
      local is_active = Devastion.lsp.is_lsp_client_active(choice)
      vim.lsp.enable(choice, not is_active)

      vim.notify(choice .. " " .. (is_active and "deactivated" or "activated"), vim.log.levels.INFO)
    end
  end)
end, { desc = "Toggle LSP Client" })

usercmd("LspListActiveClients", function()
  vim.notify(vim.inspect(Devastion.lsp.get_attached_clients()), vim.log.levels.INFO)
end, { desc = "List Active LSP Clients" })

usercmd("Template", function(args)
  local templates = Devastion.misc.get_templates()

  if args.args ~= "" and vim.tbl_contains(templates, args.args) then
    local template = vim.fn.stdpath("config") .. "/lua/devastion/templates/" .. args.args

    if vim.fn.filereadable(template) == 1 then
      local lines = vim.fn.readfile(template)

      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end

    return
  end

  vim.ui.select(templates, {
    prompt = "Select Template:",
  }, function(choice)
    if choice then
      local template = vim.fn.stdpath("config") .. "/lua/devastion/templates/" .. choice

      if vim.fn.filereadable(template) == 1 then
        local lines = vim.fn.readfile(template)

        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      end
    end
  end)
end, {
  desc = "Use Template",
  nargs = "?",
  complete = function(_, cmdline, _)
    local templates = Devastion.misc.get_templates()

    if cmdline:match("^['<,'>]*Template[!]*%s+%w*$") then
      return templates
    end
  end,
})

usercmd("DirDiff", function(opts)
  if vim.tbl_count(opts.fargs) ~= 2 then
    vim.notify("DirDiff requires exactly two directory arguments", vim.log.levels.ERROR)
    return
  end

  vim.cmd("tabnew")
  vim.cmd.packadd("nvim.difftool")
  require("difftool").open(opts.fargs[1], opts.fargs[2], {
    rename = {
      detect = false,
    },
    ignore = { ".git" },
  })
end, { complete = "dir", nargs = "*" })
