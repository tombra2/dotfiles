-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Machine-specific monitor settings stay local and are not committed. This lets
-- the same dotfiles work on both the laptop and the desktop.
local source = debug.getinfo(1, "S").source
local config_dir = source:match("^@(.*[/\\\\])") or ""
local local_file = config_dir .. "monitors.local.lua"
local file = io.open(local_file, "r")
if file then
	file:close()
	dofile(local_file)
end
