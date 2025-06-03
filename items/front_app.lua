local colors = require("colors")
local settings = require("settings")

local front_app = sbar.add("item", "front_app", {
  display = "active",
  icon = { drawing = false },
  label = {
    -- font = { family = settings.font.numbers },
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 18
    },
    color = colors.text_primary,
  },
  updates = true,
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({ label = { string = string.upper(env.INFO) } })
end)

-- front_app:subscribe("mouse.clicked", function(env)
--   sbar.trigger("swap_menus_and_spaces")
-- end)
