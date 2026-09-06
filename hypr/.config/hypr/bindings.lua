-- ALT+TAB is reserved for Herdr tab switching.
hl.unbind("ALT + TAB")
hl.unbind("SUPER + TAB")
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

o.bind("SUPER + TAB", "former workspace", hl.dsp.focus({ workspace = "previous" }))

-- SUPER+P ersetzt die Standardaktion "Pseudo window" durch den Screenshot-Dialog.
hl.unbind("SUPER + P")
o.bind("SUPER + P", "Screenshot", "omarchy-capture-screenshot")
