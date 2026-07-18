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
o.bind("SUPER + N", "obsidian daily note", "omarchy-launch-terminal " .. os.getenv("HOME") .. "/.config/hypr/scripts/obsidian-daily-note.sh")
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

-- quick-ask floating claude code instance (system-wide). toggles the window
-- hidden/shown; launches a fresh one in tmux the first time.
-- overrides super + t (default: "toggle window floating/tiling").
hl.unbind("SUPER + T")
o.bind("SUPER + T", "claude code (toggle)", {
	launch = "/home/thomas/.config/script/claude-float-toggle",
})
-- moved here from the overridden super + t default.
o.bind("SUPER + SHIFT + T", "toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

-- override super + tab (default: "next workspace") to jump to the last-used workspace.
hl.unbind("SUPER + TAB")

-- close the active window with super + q instead of super + w.
hl.unbind("SUPER + W")
o.bind("SUPER + Q", "close window", hl.dsp.window.close())

o.bind("SUPER + TAB", "former workspace", hl.dsp.focus({ workspace = "previous" }))

-- focus windows with vim keys (h/j/k/l) instead of arrows.

-- overrides: J was "toggle window split", K was "show key bindings",
-- L was "toggle workspace layout". H had no default binding.
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))
