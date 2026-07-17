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
- The config is run via a systemd user service (`~/.config/systemd/user/kanata.service`), which execs
  `kanata --cfg $HOME/.config/kanata/kanata.kbd`. To apply changes:
  ```
  systemctl --user restart kanata
  ```
  Check status/logs with `systemctl --user status kanata` / `journalctl --user -u kanata`.

## Config structure

kanata configs are built from a small set of top-level s-expression blocks; `kanata.kbd` uses:

- `defcfg` — global options. `process-unmapped-keys yes` means every key not listed in `defsrc` still
  passes through unmodified, so `defsrc`/`deflayer` only need to list the keys actually being remapped.
- `defsrc` — the physical keys being intercepted (currently `caps`, `a`, `;`), in a fixed order.
- `defalias` — named, reusable actions, referenced elsewhere with `@name`. All three aliases here use
  tap-hold variants: tap the key for its normal character, hold it to act as a modifier (e.g. `@a` types
  `a` on tap, acts as left-meta on hold). `tap-hold-release` (used for `escctrl`) waits for another key
  release to help decide tap vs. hold; plain `tap-hold` uses only the timeout.
- `deflayer` — maps each `defsrc` position (by index) to an action or alias, defining the active keymap
  layer. Position order must match `defsrc`'s order exactly.

There is also a system-wide copy at `/etc/kanata.kbd` — note this is a **separate file**, not a symlink,
so it will drift from `~/.config/kanata/kanata.kbd` unless manually kept in sync. When editing behavior,
confirm which file the running service actually points at (the user service uses the one in this repo).

## Editing conventions

- Tap-hold timeouts are `(tap-hold <tap-timeout-ms> <hold-timeout-ms> <tap-action> <hold-action>>)`;
  keep new home-row-mod-style aliases consistent with the existing 200/250ms pattern unless the user asks
  for different timing.
- After changing `defsrc`, every `deflayer` must be updated to match its new length and order — kanata
  will fail validation otherwise.
