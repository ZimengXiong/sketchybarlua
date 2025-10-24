return {
  black = 0xff181819,
  white = 0xffe2e2e3,
  red = 0xfffc5d7c,
  green = 0xff9ed072,
  blue = 0xff76cce0,
  yellow = 0xffe7c664,
  orange = 0xfff39660,
  magenta = 0xffb39df3,
  grey = 0xff7f8490,
  border = 0xff222222,
  beige_blue = 0xff98AEB6,
  purple = 0xff4A3B42,
  transparent = 0x00000000,

  -- Semantic color names for UI elements
  text_primary = 0xff0A0F1F,   -- Main text color (deep blue for light mode)
  text_secondary = 0xff9C8481, -- Secondary/inactive text
  accent = 0xffD9C2BA,         -- Accent color for highlights
  dark_bg = 0xff29456F,        -- Dark mode background color


  bar = {
    bg = 0xff1F212B,
    border = 0xff1F212B,
  },
  popup = {
    bg = 0xff1F212B,
    border = 0xff1F212B
  },
  bg1 = 0xff1F212B,
  bg2 = 0xff1F212B,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
