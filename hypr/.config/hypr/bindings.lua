hl.unbind("SUPER + ALT + RETURN")
o.rebind("SUPER + SHIFT + RETURN", "Neues Terminal", o.launch_terminal())
hl.unbind("SUPER + grave")
o.rebind("SUPER + code:49", "Fensterbreite +100 Pixel", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))

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
o.bind("ALT + SHIFT + N", "Herdr: Home workspace", "$HOME/.config/script/herdr-home-workspace")
hl.unbind("SUPER + P")
o.bind("SUPER + P", "Screenshot", "omarchy-capture-screenshot")

if o.dictation_installed and o.dictation_installed() then
	o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")
	o.bind_hold(
		"F9",
		"Start dictation (push-to-talk)",
		"omarchy-dictation start",
		"Stop dictation (push-to-talk)",
		"omarchy-dictation stop"
	)
end
