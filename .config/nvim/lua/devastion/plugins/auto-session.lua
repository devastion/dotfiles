vim.pack.add({ "https://github.com/rmagatti/auto-session" }, { confirm = false })

local options = {
  bypass_save_filetypes = { "gitcommit" },
  close_filetypes_on_save = { "checkhealth", "help" },
  git_use_branch_name = true,
  git_auto_restore_on_branch_change = true,

  save_extra_data = function(_)
    local ok, breakpoints = pcall(require, "dap.breakpoints")
    if not ok or not breakpoints then
      return
    end

    local bps = {}
    local breakpoints_by_buf = breakpoints.get()
    for buf, buf_bps in pairs(breakpoints_by_buf) do
      bps[vim.api.nvim_buf_get_name(buf)] = buf_bps
    end
    if vim.tbl_isempty(bps) then
      return
    end
    local extra_data = {
      breakpoints = bps,
    }
    return vim.fn.json_encode(extra_data)
  end,

  restore_extra_data = function(_, extra_data)
    local json = vim.fn.json_decode(extra_data)

    if json.breakpoints then
      local ok, breakpoints = pcall(require, "dap.breakpoints")

      if not ok or not breakpoints then
        return
      end
      vim.notify("restoring breakpoints")
      for buf_name, buf_bps in pairs(json.breakpoints) do
        for _, bp in pairs(buf_bps) do
          local line = bp.line
          local opts = {
            condition = bp.condition,
            log_message = bp.logMessage,
            hit_condition = bp.hitCondition,
          }
          breakpoints.set(opts, vim.fn.bufnr(buf_name), line)
        end
      end
    end
  end,
}

if package.loaded["scope"] then
  vim.schedule(function() vim.notify("scope.nvim loaded") end)
  options.pre_save_cmds = { "ScopeSaveState" }
  options.post_restore_cmds = { "ScopeLoadState", "RestoreTabPagesName", "TSContext enable" }
end

require("auto-session").setup(options)
