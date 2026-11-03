-- Focus an existing Ghostty terminal; use SUPER+SHIFT+RETURN for a new one.
-- SUPER+SHIFT+RETURN previously launched the browser.
o.rebind("SUPER + RETURN", "Terminal öffnen/fokussieren", "omarchy-launch-or-focus '^com[.]mitchellh[.]ghostty$' 'omarchy-launch-terminal'")
hl.unbind("SUPER + ALT + RETURN")
o.rebind("SUPER + SHIFT + RETURN", "Neues Terminal", o.launch_terminal())

-- SUPER+^ (physische Taste links von 1): Fensterbreite +100 Pixel.
-- Ersetzt auf dieser Taste die Quake-Konsole.
hl.unbind("SUPER + grave")
o.rebind("SUPER + code:49", "Fensterbreite +100 Pixel", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))

-- ALT+TAB is reserved for Herdr tab switching.
hl.unbind("ALT + TAB")
hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "former workspace", hl.dsp.focus({ workspace = "previous" }))
hl.unbind("CTRL + K")
hl.unbind("SUPER + W")
hl.unbind("SUPER + H")
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + DOWN")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + RIGHT")
o.bind("SUPER + H", "focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "focus right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + Q", "close window", hl.dsp.window.close())

-- Todoist als zentriertes Floating-Webapp-Fenster ein-/ausblenden.
hl.unbind("SUPER + T")
o.bind("SUPER + T", "Todoist ein/aus", "$HOME/.config/script/todoist-toggle")
-- Ursprüngliche SUPER+T-Funktion auf SUPER+SHIFT+T verschoben.
hl.unbind("SUPER + SHIFT + T")
o.bind("SUPER + SHIFT + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

-- Global shortcut: create a Herdr home workspace with nvim, pi and terminal.
o.bind("ALT + SHIFT + N", "Herdr: Home workspace", "$HOME/.config/script/herdr-home-workspace")

-- SUPER+P ersetzt die Standardaktion "Pseudo window" durch den Screenshot-Dialog.
hl.unbind("SUPER + P")
o.bind("SUPER + P", "Screenshot", "omarchy-capture-screenshot")

-- Dictation keys from before Alt + Space and Right Alt became the defaults.
-- Remove these lines to give the keys back to applications.
if o.dictation_installed and o.dictation_installed() then
  o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")
  o.bind_hold("F9", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop")
end
