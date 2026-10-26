#!/bin/sh

# Give uwsm, the browser and the 1Password tray process time to start.
sleep 8

# The desktop autostart entry starts 1Password with --silent. Toggle the
# already-running instance so the main window is visible.
if pgrep -x 1password >/dev/null 2>&1; then
  1password --toggle >/dev/null 2>&1 || true
else
  uwsm-app -- 1password >/dev/null 2>&1 &
fi

# Web apps can lose the first launch while Chromium is still starting.
for _ in 1 2 3; do
  if ! hyprctl clients -j 2>/dev/null | grep -q 'chrome-web.whatsapp.com'; then
    omarchy-launch-webapp 'https://web.whatsapp.com/' >/dev/null 2>&1 &
  fi
  sleep 5
  hyprctl clients -j 2>/dev/null | grep -q 'chrome-web.whatsapp.com' && break
done
