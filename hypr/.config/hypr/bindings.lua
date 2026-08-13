hl.unbind("SUPER + TAB")
hl.unbind("SUPER + W")
hl.unbind("SUPER + H")
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
o.bind("SUPER + Q", "close window", hl.dsp.window.close())

-- Todoist als zentriertes Floating-Webapp-Fenster ein-/ausblenden.
hl.unbind("SUPER + T")
o.bind("SUPER + T", "Todoist ein/aus", "$HOME/.config/script/todoist-toggle")
-- Ursprüngliche SUPER+T-Funktion auf SUPER+SHIFT+T verschoben.
hl.unbind("SUPER + SHIFT + T")
o.bind("SUPER + SHIFT + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

o.bind("SUPER + TAB", "former workspace", hl.dsp.focus({ workspace = "previous" }))
