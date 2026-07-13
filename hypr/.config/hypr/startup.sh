#!/bin/bash
# Hyprland login finalizer.
#
# During login the workspace rules in hyprland.lua place windows "silently"
# (no view-switch) as long as the flag below is ABSENT. This script:
#   1. pops the 1Password window (it self-starts as tray-only with --silent),
#   2. waits until the slow native apps have actually mapped,
#   3. lands the view on WS2,
#   4. creates the flag + reloads so placement becomes normal (view-following),
#   5. re-focuses WS2 after the reload settles.
# The flag lives in XDG_RUNTIME_DIR, which the system clears on every boot,
# so the next login starts "silent" again.

flag="${XDG_RUNTIME_DIR:-/tmp}/hypr-startup-done"

has() { hyprctl clients -j | grep -q "$1"; }

# 1) Open the 1Password window onto WS6. It autostarts tray-only (--silent),
#    and re-launching it once the process is ready raises the main window.
for _ in $(seq 1 20); do
  has '"class": "1password"' && break
  setsid -f uwsm-app -- 1password >/dev/null 2>&1 </dev/null
  sleep 2
done

# 2) Wait until the slow apps have mapped, so they get placed silently
#    (timeout ~30s so a missing app can't hang the rest).
for _ in $(seq 1 30); do
  has 'org.mozilla.Thunderbird' && has 'chrome-app.todoist' && has '"class": "obsidian"' && break
  sleep 1
done

# 3) Land on WS2 while still silent.
hyprctl dispatch 'hl.dsp.focus({ workspace = "2" })'

# 4) Flip placement to normal and reload.
touch "$flag"
hyprctl reload

# 5) Re-assert WS2 after the reload settles.
sleep 1
hyprctl dispatch 'hl.dsp.focus({ workspace = "2" })'
