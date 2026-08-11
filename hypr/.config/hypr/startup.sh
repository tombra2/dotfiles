#!/bin/bash
flag="${XDG_RUNTIME_DIR:-/tmp}/hypr-startup-done"

has() { hyprctl clients -j | grep -q "$1"; }

ensure_app() {
  local match="$1"
  shift

  for _ in $(seq 1 5); do
    has "$match" && return
    sleep 1
  done

  for _ in $(seq 1 3); do
    setsid -f "$@" >/dev/null 2>&1 </dev/null

    for _ in $(seq 1 5); do
      sleep 1
      has "$match" && return
    done
  done
}

for _ in $(seq 1 20); do
  has '"class": "1password"' && break
  setsid -f uwsm-app -- 1password >/dev/null 2>&1 </dev/null
  sleep 2
done

# Retry apps whose first autostart attempt did not create a window.
ensure_app '[dD]iscord' omarchy-launch-webapp 'https://discord.com/app'
ensure_app '"class": "Element"' uwsm-app -- element-desktop

for _ in $(seq 1 30); do
  has 'org.mozilla.Thunderbird' &&
    has 'chrome-app.todoist' &&
    has '"class": "obsidian"' &&
    has '[dD]iscord' &&
    has '[eE]lement' &&
    has '[wW]hatsapp' && break
  sleep 1
done

hyprctl dispatch 'hl.dsp.focus({ workspace = "2" })'

touch "$flag"
hyprctl reload

sleep 1
hyprctl dispatch 'hl.dsp.focus({ workspace = "2" })'
