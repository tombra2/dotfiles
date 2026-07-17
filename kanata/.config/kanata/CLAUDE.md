# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

This directory holds the user's personal [kanata](https://github.com/jtroo/kanata) keyboard remapper
configuration: a single file, `kanata.kbd`, written in kanata's Lisp-like config language. There is no
build system, package manifest, or test suite — it's a config file consumed directly by the `kanata`
daemon.

## Commands

- Validate the config after any edit (catches syntax errors and invalid key names without needing real
  hardware):
  ```
  kanata --check --cfg kanata.kbd
  ```
- The config runs via a systemd **user** service (`~/.config/systemd/user/kanata.service`), which execs
  `kanata --cfg $HOME/.config/kanata/kanata.kbd`. To apply changes:
  ```
  systemctl --user restart kanata
  ```
  No `sudo` needed — the user is in the `input` group. Check status/logs with
  `systemctl --user status kanata` / `journalctl --user -u kanata`.
- There's also a system-level unit (`kanata.service`, no `--user`) that used to run this same config as
  root; it's disabled now to avoid two instances fighting over the keyboard device. Leave it disabled.

## Config structure

kanata configs are built from a small set of top-level s-expression blocks; `kanata.kbd` uses:

- `defcfg` — global options. `process-unmapped-keys yes` means every key not listed in `defsrc` still
  passes through unmodified, so `defsrc`/`deflayer` only need to list the keys actually being remapped.
- `defsrc` — the physical keys being intercepted: `caps a s d f j k l ;`, in a fixed order.
- `defalias` — named, reusable actions, referenced elsewhere with `@name`. All aliases use plain
  `tap-hold`: tap the key for its normal character, hold it for the modifier. This is a home-row-mods
  setup — the mod-to-finger mapping is intentionally custom, not a straight mirror:

  | Key | Tap | Hold |
  | --- | --- | ---- |
  | `caps` | Esc | Ctrl (`escctrl`, 100/100ms) |
  | `a` | a | Meta (Super) |
  | `s` | s | Alt |
  | `d` | d | Shift |
  | `f` | f | Ctrl |
  | `j` | j | Ctrl |
  | `k` | k | Shift |
  | `l` | l | Alt |
  | `;` | ö | Meta (Super) |

  Note `d`/`f` and `j`/`k` are swapped relative to a straight GACS mirror (Shift/Ctrl sit on `d`/`j` and
  `f`/`k` respectively, not the other way round) — this was a deliberate user preference, not a mirroring
  bug. Don't "fix" it back to a symmetric layout without asking.
- `deflayer` — maps each `defsrc` position (by index) to an action or alias, defining the active keymap
  layer. Position order must match `defsrc`'s order exactly.

`/etc/kanata.kbd` is a symlink to this file (not a separate copy), but it's currently unused — the config
used to also run via a system-wide root systemd service pointed at `/etc/kanata.kbd`; that service is now
disabled in favor of the user service below, since the `input` group already grants the access
`/dev/uinput` and `/dev/input/*` need without root.

## Editing conventions

- Tap-hold timeouts are `(tap-hold <tap-timeout-ms> <hold-timeout-ms> <tap-action> <hold-action>>)`;
  keep new home-row-mod-style aliases consistent with the existing 200/250ms pattern (100/100ms for
  `escctrl`, since caps is rarely tapped) unless the user asks for different timing.
- After changing `defsrc`, every `deflayer` must be updated to match its new length and order — kanata
  will fail validation otherwise.
- Only one kanata instance can grab the physical keyboard at a time; a second instance (e.g. an
  accidentally re-enabled system service) will fail silently with "Device or resource busy" instead of
  erroring loudly, which looks like the config change "did nothing". If a config change doesn't seem to
  take effect, check `systemctl --user status kanata` and `systemctl status kanata` (system-level) aren't
  both trying to run.
