local M = {}

--- Creates lua table from string with new lines or returns
---@param s string
---@return table
function M.parse_string_to_table(s)
  local result = {}
  for line in s:gmatch("([^\r\n]+)") do
    table.insert(result, line)
  end
  return result
end

--- Split string at colon (:)
---@param s string
---@return table
function M.split_string_colon_delimiter(s) return s:match("([^:]+):(.+)") end

--- Returns sketchybar-app-font icon
---@param app_name string
---@return string
function M.get_app_icon(app_name)
  local icon_map = require("icon_map")
  local lookup = icon_map[app_name]

  return lookup == nil and icon_map["Default"] or lookup
end

--- Execute synchronous command
---@param cmd string
---@return table
function M.run_synchronous_cmd(cmd)
  local file = io.popen(cmd)

  if file ~= nil then
    local result = file:read("*a")
    file:close()
    return M.parse_string_to_table(result)
  end

  return {}
end

return M
