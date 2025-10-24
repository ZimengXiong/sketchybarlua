local colors = require("colors")
local settings = require("settings")

local front_app = sbar.add("item", {
  icon = {
    drawing = false
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Regular"],
      size = 14.0
    },
    color = colors.text_primary,
    align = "left",
    padding_left = 8,
  },
  background = {
    drawing = false
  },
  updates = true,
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({
    label = {
      string = env.INFO
    }
  })
end)
