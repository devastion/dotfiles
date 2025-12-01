local M = {}

local function job_result_ok(job)
  local ok, res = pcall(function()
    job:sync(3000)
    return job:result()
  end)
  return ok and res and res[1] or nil
end

function M.is_daemon_running()
  local Job = require("plenary.job")

  local job = Job:new({
    command = "docker",
    args = { "ps" },
  })

  local ok, code = pcall(function()
    job:sync(3000)
    return job.code
  end)

  return ok and code == 0
end

function M.get_container_id(name)
  local Job = require("plenary.job")

  local job = Job:new({
    command = "docker",
    args = { "ps", "-q", "--filter", "name=" .. name },
  })

  local id = job_result_ok(job)

  if not id or id == "" then
    vim.notify("No running container found with name: " .. name, vim.log.levels.WARN)
    return nil
  end

  return id
end

return M
