local colors = require("colors")
local settings = require("settings")

-- Equivalent to the --bar domain
sbar.bar({
  topmost = "window",
  position = "top",
  height = 37,
  color = colors.transparent,
  padding_right = settings.paddings,
  padding_left = settings.paddings,
  y_offset = 0,
  shadow = false,
})
