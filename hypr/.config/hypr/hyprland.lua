dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

require("default.hypr.omarchy")
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
require("default.hypr.toggles")

local startup_flag = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-startup-done"
local startup_file = io.open(startup_flag, "r")
local startup_complete = startup_file ~= nil
if startup_file then
	startup_file:close()
end
local silent_suffix = startup_complete and "" or " silent"

local layout = {
	top = 38,
	outer_gap = 12,
	middle_gap = 6,
}

local function workspace(number)
	return tostring(number) .. silent_suffix
end

local function place(pattern, number, rules)
	rules = rules or {}
	rules.workspace = workspace(number)
	o.window(pattern, rules)
end

local function panel_width(percent, operator, gap)
	return string.format("monitor_w*%.2f%s%d", percent, operator, gap)
end

local function panel_height()
	return "monitor_h-" .. (layout.top + layout.outer_gap)
end

local wide_width = panel_width(0.75, "-", layout.outer_gap + layout.middle_gap)
local narrow_width = panel_width(0.25, "-", layout.outer_gap + layout.middle_gap)
local right_offset = panel_width(0.25, "+", layout.middle_gap)

place("obsidian", 9, {
	float = true,
	size = { wide_width, panel_height() },
	move = { layout.outer_gap, layout.top },
})
place("^kitty$", 2)
place("[sS]potify", 3)
place(".*[tT]hunderbird.*", 4)
place(".*[dD]iscord.*", 5)
place("^[1][pP]assword$", 6, { tile = true, tag = "-floating-window" })
place("^Element$", 7, {
	float = true,
	size = { wide_width, panel_height() },
	move = { right_offset, layout.top },
})
place(".*mantis.akaryon.*", 7, {
	float = true,
	size = { narrow_width, panel_height() },
	move = { layout.outer_gap, layout.top },
})
place(".*whatsapp.*", 8)
place(".*todoist.*", 9, {
	float = true,
	size = { narrow_width, panel_height() },
	move = { panel_width(0.75, "+", layout.middle_gap), layout.top },
})
place("chromium", 10)

-- Keep every window fully opaque, overriding Omarchy's default opacity rules.
o.window(".*", { opacity = "1 1" })
