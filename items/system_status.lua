-- System Status Bar (formerly calendar.lua)
-- Displays unified system information: network, battery, volume, hostname, and time
local settings = require("settings")
local colors = require("colors")
local ui = require("helpers.ui")

ui.create_padding("status.padding")

-- Global variables to store system stats
local interface_status = "OFFLINE"
local battery_percent = "??"
local volume_percent = "??"
local hostname = "??"

local status = sbar.add("item", "unified_status", {
  icon = { drawing = false },
  label = {
    color = colors.text_status,
    padding_right = 0,
    width = 1000,
    align = "right",
    font = { family = settings.font.numbers },
  },
  position = "right",
  update_freq = 1,
  background = {
    color = colors.transparent,
    border_color = colors.transparent,
    border_width = 0
  },
})

-- Function to update the unified status display
local function update_status()
  -- Format date and time
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

  local formatted_date = day .. ", " .. month .. " " .. date .. suffix .. " at " .. time

  local status_string = interface_status .. " | " ..
      battery_percent .. "% | " ..
      volume_percent .. "% | " ..
      hostname .. " | " ..
      formatted_date

  status:set({ label = status_string })
end

local function detect_network_interfaces()
  sbar.exec([[ifconfig | awk '/^[A-Za-z0-9]+:/ { iface=$1; sub(":", "", iface); gsub("@.*", "", iface); current=iface } /status: active/ { print current }']],
    function(output)
      local interfaces = {}
      local seen = {}

      if output then
        for line in output:gmatch("[^\r\n]+") do
          local iface = line:match("%s*(.-)%s*")
          if iface and iface ~= "" then
            iface = iface:gsub("@.*", "")
            local key = iface:lower()
            if key ~= "lo0" and not seen[key] then
              seen[key] = true
              table.insert(interfaces, iface)
            end
          end
        end
      end

      if #interfaces > 0 then
        interface_status = table.concat(interfaces, " | ")
      else
        interface_status = "OFFLINE"
      end

      update_status()
    end)
end

sbar.add("event", "interface_timer")
sbar.exec("while true; do sleep 8; sketchybar --trigger interface_timer; done &")

status:subscribe("interface_timer", function(env)
  detect_network_interfaces()
end)

status:subscribe({ "forced", "routine", "system_woke" }, function(env)
  sbar.exec("hostname", function(host_info)
    hostname = host_info:gsub("%s+", "") -- Remove any whitespace/newlines
    update_status()
  end)

  sbar.exec("pmset -g batt", function(batt_info)
    local found, _, charge = batt_info:find("(%d+)%%")
    local status_indicator = ""

    if found then
      -- Determine charging status
      if batt_info:find("AC Power") then
        if batt_info:find("charged") then
          status_indicator = "AC"
        else
          status_indicator = "~" -- charging
        end
      else
        status_indicator = "!" -- discharging
      end

      battery_percent = status_indicator .. charge
    else
      battery_percent = "??"
    end
    update_status()
  end)

  sbar.exec("osascript -e 'output volume of (get volume settings)'", function(vol_info)
    local vol = tonumber(vol_info)
    if vol then
      volume_percent = tostring(vol)
    else
      volume_percent = "??"
    end
    update_status()
  end)

  update_status()
end)

ui.create_bracket("status.bracket", { status.name })
ui.create_padding("status.padding2")
