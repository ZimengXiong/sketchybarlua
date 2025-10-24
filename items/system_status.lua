-- System Status Bar (compact)
-- Shows: network interfaces | battery (with indicator) | volume | input method | time
local settings = require("settings")
local colors = require("colors")
local ui = require("helpers.ui")

ui.create_padding("status.padding")

-- Global variables
local interface_status = "OFFLINE"
local battery_percent = "??"
local volume_percent = "??"
local input_method = "??"

local status = sbar.add("item", "unified_status", {
  icon = { drawing = false },
  label = {
    color = colors.text_primary,
    padding_right = 10,
    align = "right",
    font = { family = settings.font.numbers },
  },
  position = "right",
  update_freq = 1,
  background = {
    drawing = false,
    color = 0x00000000,
    border_width = 0
  },
})

local function formatted_time()
  local day = os.date("%A")
  local month = os.date("%B")
  local date = tonumber(os.date("%d"))
  local time = os.date("%H:%M:%S")

  local suffix = "th"
  if date % 10 == 1 and date ~= 11 then
    suffix = "st"
  elseif date % 10 == 2 and date ~= 12 then
    suffix = "nd"
  elseif date % 10 == 3 and date ~= 13 then
    suffix = "rd"
  end

  return day .. ", " .. month .. " " .. date .. suffix .. " at " .. time
end

local function update_status()
  local status_string = interface_status .. " | " .. battery_percent .. " | " .. volume_percent .. " | " .. input_method .. " | " .. formatted_time()
  status:set({ label = status_string })
end

-- detect active network interfaces (en0, en4)
local function detect_network_interfaces()
  local interfaces = {}

  sbar.exec("ifconfig en0 2>/dev/null | grep 'status: active'", function(en0_result)
    if en0_result and en0_result:match("active") then
      table.insert(interfaces, "EN0")
    end

    sbar.exec("ifconfig en4 2>/dev/null | grep 'status: active'", function(en4_result)
      if en4_result and en4_result:match("active") then
        table.insert(interfaces, "EN4")
      end

      if #interfaces > 0 then
        interface_status = table.concat(interfaces, " | ")
      else
        interface_status = "OFFLINE"
      end

      update_status()
    end)
  end)
end

sbar.add("event", "interface_timer")
sbar.exec("while true; do sleep 8; sketchybar --trigger interface_timer; done &")
status:subscribe("interface_timer", function() detect_network_interfaces() end)

-- periodic updates for battery and volume
status:subscribe({ "forced", "routine", "system_woke" }, function()
  -- battery: prefix ! for discharging, ~ for charging, AC for on AC & charged
  sbar.exec("pmset -g batt", function(batt_info)
    local found, _, charge = batt_info:find("(%d+)%%")
    local status_indicator = ""

    if found and charge then
      if batt_info:find("AC Power") then
        if batt_info:find("charged") then
          status_indicator = "AC"
        else
          status_indicator = "~"
        end
      else
        status_indicator = "!"
      end

      battery_percent = status_indicator .. charge .. "%"
    else
      battery_percent = "??"
    end

    update_status()
  end)

  -- volume
  sbar.exec("osascript -e 'output volume of (get volume settings)'", function(vol_info)
    local vol = tonumber(vol_info)
    if vol then
      volume_percent = tostring(vol) .. "%"
    else
      volume_percent = "??"
    end
    update_status()
  end)

  -- input method (keyboard layout)
  sbar.exec("defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null | grep -o 'com.apple.inputmethod[^\"]*'", function(input_method_result)
    if input_method_result and input_method_result:match("%S") then
      -- Check for Chinese input methods
      if input_method_result:find("com.apple.inputmethod.Pinyin") then
        input_method = "YN"
      elseif input_method_result:find("com.apple.inputmethod.Shuangpin") then
        input_method = "YN"
      elseif input_method_result:find("com.apple.inputmethod.SCIM") then
        input_method = "YN"
      elseif input_method_result:find("com.apple.inputmethod.TCIM") then
        input_method = "YN"
      elseif input_method_result:find("com.apple.inputmethod.Wubi") then
        input_method = "YN"
      elseif input_method_result:find("com.apple.inputmethod") then
        input_method = "YN"
      else
        input_method = "EN"
      end
    else
      -- Fallback: check for keyboard layout
      sbar.exec("defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null | grep 'KeyboardLayout Name' | grep -v 'Extended'", function(keyboard_result)
        if keyboard_result and keyboard_result:match("%S") then
          input_method = "EN"
        else
          input_method = "??"
        end
      end)
    end
    update_status()
  end)

  update_status()
end)

ui.create_bracket("status.bracket", { status.name }, {
  background_color = colors.transparent,
  border_width = 0,
})
ui.create_padding("status.padding2")