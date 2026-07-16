-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Load user modules from ~/.config and Omarchy defaults from $OMARCHY_PATH.
package.path = os.getenv("HOME")
	.. "/.config/?.lua;"
	.. (os.getenv("OMARCHY_PATH") or (os.getenv("HOME") .. "/.local/share/omarchy"))
	.. "/?.lua;"
	.. package.path

-- All Omarchy default setups
require("default.hypr.omarchy")

-- Change your own setup in these files and override defaults.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Place apps silently (no view-switch) ONLY during initial login, so the
-- autostart doesn't yank the view around. autostart.lua creates this flag and
-- reloads once startup is done -> SILENT becomes "" and launching an app
-- switches to its workspace again (normal workflow). The flag lives in
-- XDG_RUNTIME_DIR, which the system clears on every boot.
local _startup_done = io.open((os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-startup-done", "r")
local SILENT = _startup_done and "" or " silent"
if _startup_done then
	_startup_done:close()
end

o.window("obsidian", { workspace = "9" .. SILENT, float = true, size = { 1771, 1300 }, move = { 12, 38 } })
o.window("^kitty$", { workspace = "2" .. SILENT })
o.window("[sS]potify", { workspace = "3" .. SILENT })
o.window(".*[tT]hunderbird.*", { workspace = "4" .. SILENT })
o.window(".*[dD]iscord.*", { workspace = "5" .. SILENT })
o.window("^(1[p|P]assword)$", { workspace = "6" .. SILENT, tile = true, tag = "-floating-window" })
o.window(".*element.io.*", { workspace = "7" .. SILENT, float = true, size = { 1771, 1300 }, move = { 617, 38 } })
o.window(".*mantis.akaryon.*", { workspace = "7" .. SILENT, float = true, size = { 591, 1300 }, move = { 12, 38 } })
o.window(".*whatsapp.*", { workspace = "8" .. SILENT })
o.window(".*todoist.*", { workspace = "9" .. SILENT, float = true, size = { 591, 1300 }, move = { 1797, 38 } })
o.window("chromium", { workspace = "10" .. SILENT })

-- Quick-ask Claude Code popup (SUPER + T): floating, centered, 50% x 50%,
-- parked on its own special workspace so it can be toggled hidden/shown
-- (see scripts/claude-float-toggle and the SUPER + T binding).
o.window(
	"^claudefloat$",
	{
		workspace = "special:claudefloat",
		float = true,
		center = true,
		size = { 1200, 675 },
		tag = "-default-opacity",
		opacity = "1 1",
	}
)
