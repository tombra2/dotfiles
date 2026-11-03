# Shortcut trainer

## Live workspace workflow

Select at least two direct numbered workspace-switch bindings, then click
"Start workspace workflow". The popup closes, keyboard inhibition ends,
and the bar shows the target workspace and shortcut. Switch workspaces normally:
green for reaching the target, red for switching elsewhere. After a correct
switch, a different target appears after 850 ms. The current workspace is
never selected as the next target. Click the widget again to stop.
The same active workflow appears on every monitor.

Only actual workspace changes are checked, not which keys caused them:
mouse clicks and other methods count too. Keys with no workspace effect
cannot be marked wrong. Move-window, relative and previous-workspace actions
are not offered in this mode. The plugin never switches workspaces itself.

IPC: `omarchy-shell thomas.shortcut-trainer startWorkspaceFlow` /
`omarchy-shell thomas.shortcut-trainer stopWorkspaceFlow`.

## Custom workspace names

Right-click the trainer to open selection. Under each direct workspace switch
is a name field: enter e.g. "Terminal" for workspace 2 or "Spotify" for 3.
Names are saved immediately in the widget's `workspaceNames` setting in
`~/.config/omarchy/shell.json` and replace the bar label (including the shortcut).
Empty fields restore the default. Names are limited to 40 characters and are
only display aliases: they do not rename Hyprland workspaces or change bindings.
Aliases also appear in isolated practice for the corresponding workspace.

## Isolated shortcut practice

Click the shortcut in the left bar to practice. Green = correct (next random
shortcut after 850 ms); red = wrong (retry the same shortcut). Escape without
modifiers, another click on the widget, or an outside click ends practice.
The dot retains the last result when you close the trainer.

Reads active, described bindings using `hyprctl -j binds` at startup and on
opening. Your custom bindings are included. Excludes locked/media bindings,
mouse, hold/release bindings, submaps, unsupported keycode-only and ambiguous
bindings, and unsupported key names. Physical number-row bindings (1–9, 0)
are supported and matched by native scan code, including Shift variants. No shortcuts are executed by this plugin.
Wayland ShortcutInhibitor explicitly inhibits Hyprland shortcuts while the
panel is open; exclusive keyboard focus alone does not inhibit keybindings.
Input is scored only while the compositor confirms inhibition is active.
Bindings configured to bypass inhibitors may still work.
Read-only diagnostics: `omarchy-shell thomas.shortcut-trainer status`.
No global key logger, network requests, config changes to Hyprland, or input
capture outside the open training panel. Scores are session-only.
On multiple monitors, the panel and score belong to the clicked widget.

Language follows Omarchy (English fallback, German included).
Colors/fonts follow the theme; feedback dots are deliberately green/red.
Run tests: `node tests/model.test.cjs`.
Disable: `omarchy plugin disable thomas.shortcut-trainer`.
