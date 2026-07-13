-- application bindings.
o.bind("SUPER + RETURN", "terminal", { omarchy = "terminal" })
o.bind("SUPER + ALT + RETURN", "tmux", { omarchy = "terminal-tmux" })
o.bind("SUPER + SHIFT + RETURN", "browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + F", "file manager", { omarchy = "nautilus" })
o.bind("SUPER + ALT + SHIFT + F", "file manager (cwd)", { omarchy = "nautilus-cwd" })
o.bind("SUPER + SHIFT + B", "browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + ALT + B", "browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + SHIFT + M", "music", { launch = "spotify", focus = "^spotify$" })
o.bind("SUPER + SHIFT + ALT + M", "music tui", { tui = "cliamp", focus = true })
o.bind("SUPER + SHIFT + N", "editor", { omarchy = "editor" })
o.bind("SUPER + SHIFT + D", "docker", { tui = "lazydocker" })
o.bind("SUPER + SHIFT + O", "obsidian", { launch = "obsidian", focus = "^obsidian$" })
o.bind("SUPER + SHIFT + W", "typora", { launch = "typora --enable-wayland-ime" })
o.bind("SUPER + SHIFT + P", "passwords", { launch = "1password" })

-- web app bindings.
o.bind("SUPER + SHIFT + A", "chatgpt", { webapp = "https://chatgpt.com" })
o.bind("SUPER + SHIFT + ALT + A", "grok", { webapp = "https://grok.com" })
o.bind("SUPER + SHIFT + C", "calendar", { webapp = "https://app.hey.com/calendar/weeks/" })
o.bind("SUPER + SHIFT + E", "email", { webapp = "https://app.hey.com" })
o.bind("SUPER + SHIFT + Y", "youtube", { webapp = "https://youtube.com/" })
o.bind("SUPER + SHIFT + ALT + G", "whatsapp", { webapp = "https://web.whatsapp.com/", focus = true })
o.bind("SUPER + SHIFT + P", "google photos", { webapp = "https://photos.google.com/", focus = true })
o.bind("SUPER + SHIFT + S", "google maps", { webapp = "https://maps.google.com/", focus = true })
o.bind("SUPER + SHIFT + X", "x", { webapp = "https://x.com/" })
o.bind("SUPER + SHIFT + ALT + X", "x post", { webapp = "https://x.com/compose/post" })

-- add extra bindings below.
-- o.bind("SUPER + SHIFT + R", "ssh", "alacritty -e ssh your-server")

-- quick-ask floating claude code instance (system-wide). raises the existing
-- window if it's already open, otherwise launches a fresh one in tmux.
-- overrides super + t (default: "toggle window floating/tiling").
hl.unbind("SUPER + T")
o.bind("SUPER + T", "claude code (float)", {
	launch = "kitty --class=claudefloat -o background_opacity=1.0 --directory=/home/thomas/session -e tmux new-session -a -s claude -c /home/thomas/session claude",
	focus = "^claudefloat$",
})
-- moved here from the overridden super + t default.
o.bind("SUPER + SHIFT + T", "toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

-- override super + tab (default: "next workspace") to jump to the last-used workspace.
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + H")
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

-- resize the active window with the arrow keys (focus is on h/j/k/l below).
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")

o.bind(
	"SUPER + LEFT",
	"shrink window width",
	hl.dsp.window.resize({ x = -100, y = 0, relative = true }),
	{ repeating = true }
)
o.bind(
	"SUPER + RIGHT",
	"grow window width",
	hl.dsp.window.resize({ x = 100, y = 0, relative = true }),
	{ repeating = true }
)
o.bind(
	"SUPER + UP",
	"shrink window height",
	hl.dsp.window.resize({ x = 0, y = -100, relative = true }),
	{ repeating = true }
)
o.bind(
	"SUPER + DOWN",
	"grow window height",
	hl.dsp.window.resize({ x = 0, y = 100, relative = true }),
	{ repeating = true }
)

-- close the active window with super + q instead of super + w.
hl.unbind("SUPER + W")
o.bind("SUPER + Q", "close window", hl.dsp.window.close())

o.bind("SUPER + TAB", "former workspace", hl.dsp.focus({ workspace = "previous" }))

-- focus windows with vim keys (h/j/k/l) instead of arrows.
o.bind("SUPER + H", "focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "focus on below window", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "focus on right window", hl.dsp.focus({ direction = "r" }))

-- overwrite existing bindings with hl.unbind() first if needed.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "omarchy menu", "omarchy-menu")
