local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 12.0
    },
    color = colors.text_status,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
    background = {
      image = { corner_radius = 0 },
      color = colors.transparent,
      border_width = 0,
      border_color = colors.transparent,
    },
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 14.0
    },
    color = colors.text_status,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    height = 28,
    corner_radius = 0,
    border_width = 0,
    border_color = colors.transparent,
    color = colors.transparent,
    image = {
      corner_radius = 0,
      border_color = colors.transparent,
      border_width = 0
    }
  },
  popup = {
    background = {
      border_width = 2,
      corner_radius = 0,
      border_color = colors.border,
      color = colors.popup.bg,
      shadow = { drawing = true },
    },
    blur_radius = 50,
  },
  scroll_texts = true,
})
