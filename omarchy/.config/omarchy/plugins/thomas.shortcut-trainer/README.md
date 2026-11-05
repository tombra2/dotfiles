# Shortcut trainer

## Live workflow (any shortcut)

Right-click the trainer, select individual shortcuts or groups and click
"Start workflow". The catalog includes active described bindings, including
media, mouse, release and submap bindings unavailable to isolated practice.
Existing selections and workspace aliases are preserved. At least one usable
task is needed. Tasks are randomized, avoiding immediate repeats where possible.
There is no automatic execution or input injection: you perform the actions.

The popup closes and keyboard inhibition ends. The bar shows the action and
shortcut (or your workspace alias). The same workflow appears on all monitors.

- Automatic: direct numbered workspace targets, closing the window focused at
  the beginning of the task, toggling that window's floating or fullscreen state,
  and directional window focus (H/J/K/L and equivalent left/right/up/down bindings).
  Focus requires a different window on the same workspace and monitor. Normal
  directional movement and edge wrap to the opposite end of the row/column count
  as success (top ↔ bottom, left ↔ right). Opposite movement from the middle
  does not count as wrap. With only one window or no focus change, use Next.
  Close menus/popups before focusing windows.
- Manual: app launches, other focus actions, move-window actions, media, menus, screenshots,
  custom actions and everything else. Selection rows label automatic/manual.
- Click **Done** in the bar to confirm a task, including an automatic task whose
  outcome was missed (e.g. no active window, delayed state capture, or failed query).
- Click **Next** to skip without scoring. Click the task itself to stop.

Green means success/confirmation; after 850 ms the next task appears. A wrong
workspace change turns red only while practicing a direct workspace target.
Unrelated changes do not mark other tasks wrong. Automatic checks measure
effects, not keypresses; other methods of producing the same effect also count.
The current workspace is excluded as a new workspace target. A single selected
workspace task can therefore finish the workflow once that workspace is reached.

**Real effects are not sandboxed**: closing, locking, shutdown, screenshots and
other potentially disruptive actions remain real when you choose those shortcuts.
Submap bindings require entering their submap yourself.

During the live workflow, shared observers query read-only `hyprctl -j clients`
and `herdr api snapshot` every 200 ms (each query has a two-second timeout).
They stay warm through feedback/task changes, so the first action of the next
exercise has a comparison state. Monitoring stops when the workflow ends.
Window checks retain addresses, geometry, workspace/monitor and floating/fullscreen
state, never titles. No global key logging.

IPC: `omarchy-shell thomas.shortcut-trainer startWorkflow`, `completeTask`,
`skipTask`, `stopWorkflow`, `status`.
The old `startWorkspaceFlow` and `stopWorkspaceFlow` commands remain aliases.

## Terminal and Herdr exercises

Selection includes two extra groups, mixed freely with Hyprland tasks:

- **Terminal · Ghostty & Bash**: effective Ghostty shortcuts from
  `ghostty +list-keybinds`, including defaults and user overrides. Bash exercises
  are labelled Emacs defaults (Ctrl+A/E, word movement, deletion, history, etc.);
  custom Readline bindings and vi mode are not discovered.
- **Herdr**: shortcuts explicitly configured in `~/.config/herdr/config.toml`
  (respects `XDG_CONFIG_HOME`). Prefix sequences are expanded, e.g.
  `Ctrl + Space → V` means press/release the prefix, then V.
  Array alternatives and ranges such as `1..9` are individual selectable tasks.
  Custom commands contribute their key and description, never their command body.
  Unconfigured Herdr default bindings are not guessed.

These app-internal exercises are **workflow-only**; they cannot be selected for
isolated keyboard scoring. Ghostty/Bash exercises retain **Done** confirmation.
Perform them in the appropriate terminal/Herdr pane, ideally at a disposable
prompt; Ctrl+C/D and close shortcuts really interrupt/close things.

Herdr automatic verification (tested with client/server 0.9.5, protocol 22):
- `focus_pane_left/right/up/down`: a different pane in the same tab, measured
  using the baseline geometry. Directional movement and boundary wrap to the
  opposite extreme count; backwards movement from the middle does not.
- `split_vertical/horizontal`: exactly one additional pane and split in the same
  tab, with the expected split direction (right/down).
- `zoom`: a change in the same tab's zoom state, both on and off.
- `previous_tab/next_tab`: the adjacent numbered tab, including cyclic wrap;
  `switch_tab`: the configured number (including expanded prefix alternatives).
- `previous_workspace/next_workspace`: the adjacent numbered workspace, including
  cyclic wrap. These are Herdr workspaces, not Hyprland workspaces or aliases.

The Herdr observer queries `timeout 2s herdr api snapshot` during the workflow,
against the local session resolved by the shell's CLI environment (normally the
default local session).
It does not follow a remote machine selected in the TUI. A snapshot supplies
focus, ordered tabs/workspaces and pane layouts coherently; only IDs, numbers,
geometry, split directions and zoom flags are retained in memory. No terminal
contents, titles, commands or agent data are retained or logged.

Task selection waits for the first Herdr query. Observable Herdr tasks that
cannot currently change state are excluded: up/down in a horizontal-only layout,
focus into an empty direction, zoom with one pane, switching to a nonexistent or
already active tab, and relative switches with only one tab/workspace. Your saved
selection is never modified. Manual/API-unavailable tasks retain Done as fallback.
If no selected task is currently executable, the workflow ends.

Herdr compares successive snapshots, so preparing an action in another tab or
after changing the layout does not leave it stuck on the original context.
Hyprland close/floating/fullscreen checks still target the window at task start.
Late responses from earlier task generations are discarded; failed queries clear
the comparison state. Public Herdr IDs are opaque handles (including letters,
such as `w19A:pB`), not decimal counters. No change, a single-pane focus, or
switching to an already active tab is not a success.
Polling can miss very fast changes that return to the original state. **Done**
remains available for all tasks, including unavailable/older Herdr APIs. Help,
copy/resize modes, picker dialogs, renaming, custom commands, creation/closing
of tabs/workspaces and other unimplemented actions remain manual. No keypress
interception, automatic action execution or input injection is used.

Catalogs refresh on opening the panel and at shell startup. Failed discovery is
reported in the panel; the other sources remain usable. Existing selected IDs
are preserved; new application exercises start unselected in an existing set.

Tests: `python3 tests/catalog_test.py`, `node tests/herdr.test.cjs` and
`node tests/model.test.cjs`.

For explicit single-task diagnostics without changing the saved selection:
`omarchy-shell thomas.shortcut-trainer startWorkflowTask herdr:zoom:prefix+z`.
Normal randomized progression resumes after success. `status` includes
`revision` (`herdr-state-v2`), `herdrAvailable`, `herdrBaselineReady`,
`herdrTaskPossible`, focused pane ID, exit code/output size and sample counters.
After code changes, verify this revision is running. If a plugin rescan retains
old QML/JS, use `omarchy restart shell` before testing.

Opt-in real keyboard/TUI test (requires the focused local Herdr window, wtype
and the configured Ctrl+Space prefix):
`python3 tests/live_herdr_test.py --run`.
It exercises both splits, all four focus directions, zoom on/off, relative and
numbered tabs including tab wrap, workspace changes, preparation in another
tab/layout, then eight consecutive randomized tasks. Input is guarded by the
active window and owned workspace IDs. Only its newly created resources are
closed; original panes and saved settings are checked afterward. Pane boundary
wrap comparison has unit coverage; no-op edge focus is not scored as success.

## Structure

- `catalog.py`: read-only shortcut discovery; stable selection IDs unchanged.
- `Herdr.js`: single source for supported Herdr actions, snapshot validation,
  contextual availability and outcome comparison.
- `Model.js`: task selection, Hyprland/keyboard checks and display helpers;
  imports the Herdr rules rather than maintaining a second action list.
- `StateObserver.qml`: shared timeout, polling, successful-exit validation,
  generation handling and latest/comparison state for both backends.
- `BarWidget.qml`: workflow/UI orchestration; settings writes and workflow
  startup share one implementation each.
- `tests/load.cjs`: loads the same QML JS imports for both Node test suites.

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
