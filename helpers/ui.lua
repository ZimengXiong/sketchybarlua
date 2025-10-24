local colors = require("colors")
local settings = require("settings")

local ui = {}

-- Create a standard bracket with consistent styling
function ui.create_bracket(name, items, opts)
    opts = opts or {}
    local bracket_config = {
        background = {
            color = opts.background_color or colors.bg1,
            height = opts.height or settings.bracket_height,
            border_width = opts.border_width or settings.border_width,
            border_color = opts.border_color or colors.border,
        }
    }

    -- Add popup configuration if provided
    if opts.popup then
        bracket_config.popup = opts.popup
    end

    return sbar.add("bracket", name, items, bracket_config)
end

-- Create a standard padding item
function ui.create_padding(name, width, position, drawing)
    return sbar.add("item", name, {
        position = position or "right",
        width = width or settings.group_paddings,
        drawing = drawing ~= false, -- default to true unless explicitly false
    })
end

-- Standard widget configuration
function ui.widget_defaults()
    return {
        position = "right",
        label = {
            color = colors.text_primary,
            font = { family = settings.font.numbers }
        },
        icon = {
            color = colors.text_primary,
            font = {
                style = settings.font.style_map["Regular"],
                size = 14.0,
            }
        }
    }
end

-- Standard popup configuration
function ui.popup_defaults()
    return {
        align = "center",
        background = {
            border_width = 2,
            corner_radius = settings.corner_radius,
            border_color = colors.border,
            color = colors.popup.bg,
            shadow = { drawing = true },
        },
        blur_radius = 50,
    }
end

return ui