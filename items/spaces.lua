local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}

-- Get the maximum space index from yabai
local handle = io.popen("yabai -m query --spaces | jq '.[-1].index'")
local max_spaces = 11                  -- fallback
if handle then
  max_spaces = handle:read("*n") or 11 -- read as a number
  handle:close()
end

for i = 1, max_spaces, 1 do
  local space = sbar.add("space", "space." .. i, {
    space = i,
    icon = {
      font = {
        family = settings.font.text,
        style = settings.font.style_map["Regular"],
        size = 18
      },
      string = i,
      padding_left = 5,
      padding_right = 5,
      color = colors.text_status,
      highlight_color = colors.text_status,
    },
    label = {
      padding_right = 5,
      color = colors.text_status,
      highlight_color = colors.text_status,
      font = "sketchybar-app-font:Regular:16.0",
      y_offset = -1,
    },
    -- color = color.transparent,
    background = {
      color = colors.transparent,
      border_width = 0,
      height = 26,
      border_color = colors.transparent,
      padding_right = 15, -- Move padding to background to control color
      -- border_color = colors.yellow,
    },
    -- popup = { background = { border_width = 5, border_color = colors.black } }
  })

  spaces[i] = space

  local space_bracket = sbar.add("bracket", { space.name }, {
    background = {
      color = colors.transparent,
      border_color = colors.transparent,
      height = 28,
      border_width = 0
    }
  })

  -- Padding space
  sbar.add("space", "space.padding." .. i, {
    space = i,
    script = "",
    width = settings.group_paddings,
  })

  local space_popup = sbar.add("item", {
    position = "popup." .. space.name,
    padding_left = 0,
    padding_right = 0,
    background = {
      drawing = true,
      image = {
        corner_radius = 0,
        scale = 0.2
      }
    }
  })

  space:subscribe("space_change", function(env)
    local selected = env.SELECTED == "true"
    space:set({
      icon = {
        highlight = selected,
        font = {
          family = settings.font.text,
          style = settings.font.style_map[selected and "Bold" or "Regular"],
          size = 18
        }
      },
      label = { highlight = selected },
      background = { border_color = colors.transparent }
    })
    space_bracket:set({
      background = { border_color = colors.transparent }
    })
  end)

  space:subscribe("mouse.clicked", function(env)
    if env.BUTTON == "other" then
      -- Right click functionality could be added here
    else
      sbar.exec("sh /Users/zimengx/code/scripts/change_spaces.sh " .. env.SID)
    end
  end)
end

local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
})

space_window_observer:subscribe("space_windows_change", function(env)
  local icon_line = ""
  local no_app = true
  local apps = (env.INFO and env.INFO.apps) or {}
  for app, count in pairs(apps) do
    no_app = false
    local lookup = app_icons[app]
    local icon = lookup or app_icons["Default"] or ""
    if icon ~= "" then
      icon_line = icon_line .. " " .. icon
    end
  end

  if (no_app) then
    icon_line = " —"
  end
  sbar.animate("tanh", 10, function()
    spaces[env.INFO.space]:set({ label = icon_line })
  end)
end)
