-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- The Omarchy update added shift:both_capslock_cancel, which intercepts
-- pressing both Shift keys and prevents JetBrains' Shift Shift shortcut.
-- Keep the previous keyboard options for PhpStorm's double-Shift action.
hl.config({
  input = {
    kb_layout = "de",
    kb_file = "/home/thomas/.config/xkb/de-custom.xkb",
    -- CapsLock is handled by Kanata (tap = Escape, hold = Ctrl).
    kb_options = "",
  },
})

-- Touchpad optimized for laptop use: natural scrolling, tap-to-click and
-- two-finger right-click/scrolling. Typing temporarily disables the pad.
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

-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Three-finger horizontal swipe: switch workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
