hl.config({
	input = {
		kb_layout = "de",
		kb_options = "compose:caps",
	},
})

hl.config({
	input = {
		touchpad = {
			natural_scroll = true,
			clickfinger_behavior = true,
			scroll_factor = 0.6,
			disable_while_typing = true,
		},
	},
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
