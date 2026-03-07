local Docker = {}

Docker.cmd = "docker"

Docker.cache = {}

function Docker.is_daemon_running(callback)
  vim.system({ Docker.cmd, "version", "--format", "{{.Server.Version}}" }, {}, function(obj)
    vim.schedule(function()
      callback(obj.code == 0)
    end)
  end)
end

---Find container's id
---@param filter? "name"|"publish"
---@param value? string
---@param callback? function
---@return string?
function Docker.get_container_id(filter, value, callback)
  if Docker.cache.container_id then
    vim.notify("Docker container id is cached. [" .. Docker.cache.container_id .. "]", vim.log.levels.DEBUG)
    if callback then
      vim.schedule(function()
        callback(Docker.cache.container_id)
      end)
    else
      return Docker.cache.container_id
    end
  end

  if filter and value then
    vim.system({ Docker.cmd, "ps", "-q", "--filter", filter .. "=" .. value }, {}, function(obj)
      local container_id = vim.trim(obj.stdout)

      if container_id == "" then
        vim.notify("No running container with " .. filter .. ": " .. value, vim.log.levels.INFO)
        return
      end

      Docker.cache.container_id = container_id

      if callback then
        vim.schedule(function()
          callback(Docker.cache.container_id)
        end)
      end
    end)
  end
end

function Docker.get_container_workdir(container_id)
  if Docker.cache.container_workdir then
    vim.notify(
      "Docker container workdir for container with id "
        .. container_id
        .. " is cached. ["
        .. Docker.cache.container_workdir
        .. "]",
      vim.log.levels.DEBUG
    )
    return Docker.cache.container_workdir
  end

  local container_workdir =
    vim.trim(vim.system({ Docker.cmd, "inspect", "--format", "{{.Config.WorkingDir}}", container_id }):wait().stdout)

  if not container_workdir or container_workdir == "" then
    vim.notify("No workdir for container with id: " .. container_id, vim.log.levels.ERROR)
    return
  end

  Docker.cache.container_workdir = container_workdir

  return container_workdir
end

function Docker.get_container_shell(container_id)
  if Docker.cache.container_shell then
    vim.notify(
      "Docker container shell for container with id "
        .. container_id
        .. " is cached. ["
        .. Docker.cache.container_shell
        .. "]",
      vim.log.levels.DEBUG
    )
    return Docker.cache.container_shell
  end

  local container_shell = vim.trim(vim
    .system({
      Docker.cmd,
      "exec",
      "-i",
      container_id,
      "/bin/sh",
      "-c",
      "if [ -f /bin/sh ]; then echo /bin/sh; else echo /bin/bash; fi | tr -d '\r'",
    })
    :wait().stdout)
  if not container_shell or container_shell == "" then
    vim.notify("Shell path not found for container with id: " .. container_id, vim.log.levels.ERROR)
    return
  end

  Docker.cache.container_shell = container_shell

  return container_shell
end

return Docker
