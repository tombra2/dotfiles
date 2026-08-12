hl.unbind("SUPER + TAB")
hl.unbind("SUPER + W")
hl.unbind("SUPER + H")
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
o.bind("SUPER + Q", "close window", hl.dsp.window.close())

o.bind("SUPER + TAB", "former workspace", hl.dsp.focus({ workspace = "previous" }))
