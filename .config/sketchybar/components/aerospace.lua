local constants = require("constants")
local colors = constants.colors
local helper = require("helper")

local AEROSPACE = {
  events = {
    workspace_change = "aerospace_workspace_change",
    focus_change = "aerospace_focus_change",
  },
  commands = {
    list_workspaces = "aerospace list-workspaces --all",
    list_windows = function(workspace_name)
      return "aerospace list-windows --format '%{window-id}:%{app-name}' --workspace " .. workspace_name
    end,
    focus_workspace = function(workspace_name) return "aerospace workspace " .. workspace_name end,
    focus_window = function(window_id) return "aerospace focus --window-id " .. window_id end,
  },
}

for ws_idx, ws_name in ipairs(helper.run_synchronous_cmd(AEROSPACE.commands.list_workspaces)) do
  local WORKSPACE_BRACKET = {}
  WORKSPACE_BRACKET[ws_name] = {}

  local ws_item = SBar.add("item", ws_name, {
    label = {
      string = ws_idx,
      color = colors.dark,
      highlight_color = colors.white,
      padding_left = constants.spacing.lg,
      padding_right = constants.spacing.lg,
    },
    click_script = AEROSPACE.commands.focus_workspace(ws_name),
  })

  table.insert(WORKSPACE_BRACKET[ws_name], ws_item.name)

  ws_item:subscribe(AEROSPACE.events.workspace_change, function(env)
    local is_selected = env.FOCUSED_WORKSPACE == ws_name
    ws_item:set({
      label = { highlight = is_selected },
    })
  end)

  for _k, v in ipairs(helper.run_synchronous_cmd(AEROSPACE.commands.list_windows(ws_name))) do
    local window_id, window_app_name = helper.split_string_colon_delimiter(v)
    local icon = helper.get_app_icon(window_app_name)

    local window_item = SBar.add("item", window_id, {
      icon = {
        string = icon,
        padding_right = constants.spacing.lg,
        color = colors.dark,
        highlight_color = colors.red,
      },
      click_script = AEROSPACE.commands.focus_window(window_id),
    })

    table.insert(WORKSPACE_BRACKET[ws_name], window_item.name)

    window_item:subscribe(AEROSPACE.events.focus_change, function(env)
      local is_focused = env.FOCUSED_WINDOW == window_id
      window_item:set({
        icon = {
          highlight = is_focused,
        },
      })
    end)
  end

  SBar.add("bracket", WORKSPACE_BRACKET[ws_name], {
    background = {
      height = 32,
      color = colors.bg,
      border_color = colors.border,
      border_width = 2,
      corner_radius = 8,
    },
  })

  SBar.add("item", "bracket.padding." .. ws_name, {
    width = constants.spacing.md,
  })
end
