local colors = require("colors")
local settings = require("settings")

-- Equivalent to the --bar domain
sbar.bar({
  topmost = "window",
  position = "bottom",
  height = 45,
  color = colors.bar.bg,
  padding_right = settings.paddings,
  padding_left = settings.paddings,
  y_offset = 0,
  shadow = true,
})
