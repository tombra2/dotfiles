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

local function workspace(number)
	return tostring(number) .. silent_suffix
end

local function place(pattern, number, rules)
	rules = rules or {}
	rules.workspace = workspace(number)
	o.window(pattern, rules)
end

place("^kitty$", 2)
place("[sS]potify", 3)
place(".*[tT]hunderbird.*", 4)
place(".*[dD]iscord.*", 5)
place("^[1][pP]assword$", 6, { tile = true, tag = "-floating-window" })
place("^[eE]lement$", 7)
place(".*[oO]bsidian.*", 9)
place(".*[wW]hatsapp.*", 8)
place("chromium", 10)

-- Todoist-Popup liegt auf einem eigenen Special-Workspace und wird per SUPER+T getoggelt.
o.window({ class = "chrome-app.todoist.com__app_today-Default" }, {
	workspace = "special:chrome-todoist-window",
	float = true,
	center = true,
	size = { "monitor_w*0.70", "monitor_h*0.75" },
})

-- Keep every window fully opaque.
o.window(".*", { opacity = "1 1" })
