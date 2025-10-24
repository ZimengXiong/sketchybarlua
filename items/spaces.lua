local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}

-- get all workspaces from aerospace
local function get_aerospace_workspaces()
  local workspaces = {}
  local handle = io.popen("aerospace list-workspaces --all")
  if handle then
    for workspace in handle:lines() do
      table.insert(workspaces, workspace)
    end
    handle:close()
  end
  return workspaces
end

-- get apps for a specific workspace
local function get_workspace_apps(workspace_id)
  local apps = {}
  local handle = io.popen("aerospace list-windows --workspace " .. workspace_id)
  if handle then
    for line in handle:lines() do
      -- Parse the app name from the window info
      -- Format is: "window_id | App Name | Window Title"
      local app_name = line:match("^%s*[^|]+%s*|%s*(.-)%s*|")
      if app_name and app_name ~= "" then
        table.insert(apps, app_name)
      end
    end
    handle:close()
  end
  return apps
end

-- map app name to icon
local function get_app_icon(app_name)
  -- Clean up the app name (remove extra spaces)
  app_name = app_name:gsub("^%s*(.-)%s*$", "%1")

  -- Try different variations of the app name for better matching
  local variations = {
    app_name,
    app_name:gsub("%s+%d*$", ""), -- Remove trailing numbers (version info)
    app_name:gsub("%s+%([^)]*%)", ""), -- Remove parenthetical info
    app_name:match("^([^%s]+)"), -- Just the first word
  }

  for _, variation in ipairs(variations) do
    if app_icons[variation] then
      return app_icons[variation]
    end
  end

  -- If no match found, return default icon
  return ":default:"
end

-- create icon strip for workspace apps
local function create_icon_strip(workspace_id)
  local apps = get_workspace_apps(workspace_id)

  if #apps > 0 then
    local icon_strip = " "
    for _, app in ipairs(apps) do
      local icon = get_app_icon(app)
      icon_strip = icon_strip .. icon .. " "
    end
    return icon_strip
  else
    return "" -- Return empty string for empty workspaces
  end
end

local workspaces = get_aerospace_workspaces()

-- Create space items for each workspace
for _, workspace_id in ipairs(workspaces) do
  local space = sbar.add("item", "space." .. workspace_id, {
    position = "left",
    icon = {
      font = {
        family = settings.font.text,
        style = settings.font.style_map["Regular"],
        size = 16
      },
      string = workspace_id,
      padding_left = 8,
      padding_right = 8,
      color = colors.text_primary,
      y_offset = 0,
    },
    label = {
      font = {
        family = "sketchybar-app-font", -- Use the app icon font
        style = settings.font.style_map["Regular"],
        size = 16
      },
      padding_left = 4,
      padding_right = 8,
      color = colors.text_primary,
      y_offset = -1, -- Slightly adjust icon alignment
    },
    background = {
      height = 24,
      corner_radius = 12,
      border_width = 0,
    },
    click_script = "aerospace workspace " .. workspace_id,
  })

  -- Set initial icon strip
  local icon_strip = create_icon_strip(workspace_id)
  space:set({
    icon = { string = workspace_id },
    label = { string = icon_strip }
  })

  -- Subscribe to workspace change events
  space:subscribe("aerospace_workspace_change", function(env)
    local focused_workspace = env.FOCUSED_WORKSPACE
    local is_focused = (focused_workspace == workspace_id)

    if is_focused then
      space:set({
        background = {
          drawing = true,
          color = { alpha = 0 }, -- Transparent background
          border_color = colors.text_primary,
          border_width = 2,
          corner_radius = "0x04100404", -- top-left:12, top-right:6, bottom-right:6, bottom-left:6
          height = 26,
        },
        icon = { color = colors.text_primary },
        label = { color = colors.text_primary }
      })
    else
      space:set({
        background = {
          drawing = false,
          border_width = 0,
        },
        icon = { color = colors.text_primary },
        label = { color = colors.text_primary }
      })
    end

    -- Update the icon strip for this workspace
    local new_icon_strip = create_icon_strip(workspace_id)
    space:set({ label = { string = new_icon_strip } })
  end)
end

-- Add global event subscription
sbar.add("event", "aerospace_workspace_change")

-- Get current focused workspace for initial state
local handle = io.popen("aerospace list-workspaces --focused")
local current_workspace = "1" -- fallback
if handle then
  current_workspace = handle:read("*l") or "1"
  handle:close()
end

-- Trigger initial workspace state
sbar.trigger("aerospace_workspace_change", { FOCUSED_WORKSPACE = current_workspace })

local function update_workspace_icons()
  for _, workspace_id in ipairs(workspaces) do
    local icon_strip = create_icon_strip(workspace_id)
    sbar.set("space." .. workspace_id, { label = { string = icon_strip } })
  end
end

-- Subscribe to window events to update icons in real-time
sbar.add("event", "aerospace_window_event")
sbar.subscribe("aerospace_window_event", update_workspace_icons)
