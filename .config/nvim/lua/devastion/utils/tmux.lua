local M = {}

function M.get_tmux_leader()
  if not vim.g.tmux_leader_key then
    vim.g.tmux_leader_key = vim.system({ "tmux", "show", "-gv", "prefix" }, {}):wait().stdout:match("%S+")
  end

  return vim.g.tmux_leader_key
end

function M.toggle_tmux_leader(mode)
  if mode == "i" then
    vim.system({ "tmux", "set-option", "-p", "prefix", "None" }, {})
  else
    vim.system({ "tmux", "set-option", "-p", "prefix", M.get_tmux_leader() }, {})
  end
end

function M.create_user_command()
  vim.api.nvim_create_user_command("ResetTmuxLeader", function()
    vim.system({ "tmux", "set-option", "-g", "prefix", M.get_tmux_leader() }, {})
    vim.notify("Leader set to C-Space", vim.log.levels.INFO, { title = "TMux" })
  end, {})
end

function M.create_auto_command()
  vim.api.nvim_create_autocmd({ "ModeChanged" }, {
    group = vim.api.nvim_create_augroup("i_tmux_unset_leader", {}),
    desc = "Disable TMux leader in insert mode",
    callback = function(args)
      local new_mode = args.match:sub(-1)
      M.toggle_tmux_leader(new_mode)
    end,
  })
end

function M.setup()
  local is_tmux = os.getenv("TMUX")
  if is_tmux then
    M.create_auto_command()
    M.create_user_command()
  end
end

return M
