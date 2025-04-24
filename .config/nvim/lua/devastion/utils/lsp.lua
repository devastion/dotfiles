local M = {}

---Get all configurations in lsp/*
---@return table
function M.lsp_configs()
  local lsp_configs = {}

  for _, v in ipairs(vim.api.nvim_get_runtime_file("lsp/*", true)) do
    local name = vim.fn.fnamemodify(v, ":t:r")
    table.insert(lsp_configs, name)
  end

  return lsp_configs
end

function M.mason_install(packages)
  local mr = require("mason-registry")

  mr.refresh(function()
    for _, tool in ipairs(packages) do
      local p = mr.get_package(tool)
      if not p:is_installed() then
        p:install()
      end
    end
  end)
end

---Get list of attached lsp clients
---@return string
function M.get_attached_clients()
  -- Get active clients for current buffer
  local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
  if #buf_clients == 0 then
    return "No client active"
  end
  local buf_ft = vim.bo.filetype
  local buf_client_names = {}
  local num_client_names = #buf_client_names

  -- Add lsp-clients active in the current buffer
  for _, client in pairs(buf_clients) do
    num_client_names = num_client_names + 1
    buf_client_names[num_client_names] = client.name
  end

  -- Add linters for the current filetype (nvim-lint)
  local lint_success, lint = pcall(require, "lint")
  if lint_success then
    for ft, ft_linters in pairs(lint.linters_by_ft) do
      if ft == buf_ft then
        if type(ft_linters) == "table" then
          for _, linter in pairs(ft_linters) do
            num_client_names = num_client_names + 1
            buf_client_names[num_client_names] = linter
          end
        else
          num_client_names = num_client_names + 1
          buf_client_names[num_client_names] = ft_linters
        end
      end
    end
  end

  -- Add formatters (conform.nvim)
  local conform_success, conform = pcall(require, "conform")
  if conform_success then
    for _, formatter in pairs(conform.list_formatters_for_buffer(0)) do
      if formatter then
        num_client_names = num_client_names + 1
        buf_client_names[num_client_names] = formatter
      end
    end
  end

  local client_names_str = table.concat(buf_client_names, ", ")
  local language_servers = string.format("[%s]", client_names_str)

  return language_servers
end

---Checks if composer.json contains laravel/framework
---@return boolean
function M.is_laravel()
  local composer = vim.fn.getcwd() .. "/composer.json"
  local is_readable = vim.fn.filereadable(composer) ~= 0

  if is_readable then
    local is_laravel = vim.system({ "jq", '.require."laravel/framework"', composer }, {}):wait().stdout
    if is_laravel then
      return true
    end
  end

  return false
end

function M.is_typescript()
  local package_json = vim.fn.getcwd() .. "/package.json"
  local is_readable = vim.fn.filereadable(package_json) ~= 0

  if is_readable then
    local is_typescript = vim.system({ "jq", '.devDependencies."typescript"', package_json }, {}):wait().stdout
    if is_typescript then
      return true
    end
  end

  return false
end

function M.tailwind_config_exists()
  local current_dir = require("devastion.utils.path").get_root_directory()
  local config_files = {
    "tailwind.config.js",
    "tailwind.config.cjs",
    "tailwind.config.mjs",
    "tailwind.config.ts",
    "postcss.config.js",
    "postcss.config.cjs",
    "postcss.config.mjs",
    "postcss.config.ts",
  }

  for _, file in ipairs(config_files) do
    local config_file = current_dir .. "/" .. file
    if vim.fn.filereadable(config_file) == 1 then
      return true
    end
  end

  local package_json = vim.fn.getcwd() .. "/package.json"
  local is_readable = vim.fn.filereadable(package_json) ~= 0

  if is_readable then
    local is_tailwind = vim.system({ "jq", '.devDependencies."tailwindcss"', package_json }, {}):wait().stdout
    if is_tailwind ~= nil and string.len(is_tailwind) > 5 then
      return true
    end
  end

  return false
end

return M
