-- System Status Bar (formerly calendar.lua)
-- Displays unified system information: memory, CPU, network, battery, volume, hostname, and time
local settings = require("settings")
local colors = require("colors")
local ui = require("helpers.ui")

-- Execute event providers for system data
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")
sbar.exec(
  "killall memory_pressure >/dev/null; $CONFIG_DIR/helpers/event_providers/bin/memory_pressure memory_pressure_update 5.0")

ui.create_padding("status.padding")

-- Global variables to store system stats
local cpu_load = "??"
local memory_usage = "??"
local memory_pressure_level = 0
local memory_pressure_status = "NORMAL"
local swap_usage = "??"
local interface_status = "OFFLINE"
local battery_percent = "??"
local volume_percent = "??"
local hostname = "??"

local status = sbar.add("item", "unified_status", {
  icon = { drawing = false },
  label = {
    color = colors.text_primary,
    padding_right = 0,
    width = 1000,
    align = "right",
    font = { family = settings.font.numbers },
  },
  position = "right",
  update_freq = 1,
  background = {
    color = colors.bg1,
    border_color = colors.border,
    border_width = 0.5
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

  local pressure_indicator = ""
  if memory_pressure_level > 0 then
    pressure_indicator = " [" .. memory_pressure_level .. "]"
  end

  local status_string = "MEM " .. memory_usage .. "%" .. pressure_indicator .. " | " ..
      "SWAP " .. swap_usage .. "% | " ..
      "CPU " .. cpu_load .. "% | " ..
      interface_status .. " | " ..
      battery_percent .. "%B | " ..
      volume_percent .. "%S | " ..
      hostname .. " | " ..
      formatted_date

  status:set({ label = status_string })
end

-- CPU update subscription
status:subscribe("cpu_update", function(env)
  cpu_load = env.total_load
  update_status()
end)

-- Memory pressure update subscription
status:subscribe("memory_pressure_update", function(env)
  memory_pressure_level = tonumber(env.pressure_level) or 0
  memory_pressure_status = env.pressure_status or "NORMAL"
  local swap_percent = tonumber(env.swap_percentage) or 0
  swap_usage = string.format("%.1f", swap_percent)
  update_status()
end)

local function detect_network_interfaces()
  local interfaces = {}

  -- Check en0
  sbar.exec("ifconfig en0 2>/dev/null | grep 'status: active'", function(en0_result)
    if en0_result and en0_result:match("active") then
      table.insert(interfaces, "EN0")
    end

    -- Check en4
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

status:subscribe("interface_timer", function(env)
  detect_network_interfaces()
end)

status:subscribe({ "forced", "routine", "system_woke" }, function(env)
  -- Update memory usage (only active + wired, excluding cached/inactive)
  sbar.exec(
    "vm_stat | awk '/Pages free/ {free=$3} /Pages active/ {active=$3} /Pages inactive/ {inactive=$3} /Pages speculative/ {spec=$3} /Pages wired/ {wired=$3} END {total=free+active+inactive+spec+wired; used=active+wired; if(total>0) print int((used/total)*100); else print 0}'",
    function(mem_info)
      local mem_usage = tonumber(mem_info)
      if mem_usage then
        memory_usage = tostring(mem_usage)
      else
        memory_usage = "??"
      end
      update_status()
    end)

  sbar.exec("hostname", function(host_info)
    hostname = host_info:gsub("%s+", "") -- Remove any whitespace/newlines
    update_status()
  end)

  sbar.exec("pmset -g batt", function(batt_info)
    local found, _, charge = batt_info:find("(%d+)%%")
    if found then
      battery_percent = charge
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
