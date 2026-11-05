"""Opt-in real TUI test. Only creates/closes its own workspaces and terminals.
Run from the focused local Herdr window: python3 tests/live_herdr_test.py --run
Requires wtype, the user's current Ctrl+Space prefix and configured bindings.
"""
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import tomllib


def run(*args):
    p = subprocess.run(args, capture_output=True, text=True, timeout=8, check=True)
    return json.loads(p.stdout) if p.stdout.strip() else None


def herdr(*args):
    return run("herdr", *args)["result"]


def ipc(method, *args):
    return run("omarchy-shell", "thomas.shortcut-trainer", method, *args)


def snapshot():
    return herdr("api", "snapshot")["snapshot"]


def wait(predicate, timeout=5):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        state = ipc("status")
        if predicate(state):
            return state
        time.sleep(.04)
    raise AssertionError(state)


def settings():
    config = json.loads((Path.home()/".config/omarchy/shell.json").read_text())
    def find(value):
        if isinstance(value, dict):
            if value.get("id") == "thomas.shortcut-trainer":
                return value
            for child in value.values():
                found = find(child)
                if found is not None:
                    return found
        if isinstance(value, list):
            for child in value:
                found = find(child)
                if found is not None:
                    return found
    return find(config)


def press(binding):
    # Never inject into another app or any existing user pane/workspace.
    s = snapshot()
    assert s["focused_workspace_id"] in created
    active = run("hyprctl", "-j", "activewindow")
    assert active["address"] == window and active["title"].endswith(tuple(labels))
    args = ["wtype"]
    for index, chord in enumerate(binding.replace("prefix+", "ctrl+space ").split()):
        if index:
            args.extend(["-s", "80"])
        parts = chord.split("+")
        for modifier in parts[:-1]:
            args.extend(["-M", modifier])
        args.extend(["-k", parts[-1]])
        for modifier in reversed(parts[:-1]):
            args.extend(["-m", modifier])
    subprocess.run(args, check=True, timeout=3)


def exercise(action, binding):
    assert ipc("startWorkflowTask", "herdr:"+action+":"+binding)
    wait(lambda s: s["herdrBaselineReady"] and s["revision"] == "herdr-state-v2")
    press(binding)
    state = wait(lambda s: s["correct"] == 1 and s["result"] == 1)
    assert not state["inhibited"]
    ipc("stopWorkflow")
    print("PASS real shortcut:", action, flush=True)


if "--run" not in sys.argv:
    sys.exit("Opt-in required: --run (creates temporary workspaces and sends real shortcuts)")
if os.environ.get("HERDR_ENV") != "1":
    sys.exit("Must run inside Herdr")
keys = tomllib.loads((Path.home()/".config/herdr/config.toml").read_text())["keys"]
assert keys["prefix"] == "ctrl+space"
original = snapshot()
original_settings = settings()
window = run("hyprctl", "-j", "activewindow")["address"]
created = []
labels = ["trainer-live-test-A", "trainer-live-test-B"]
try:
    for label in labels:
        result = herdr("workspace", "create", "--label", label, "--cwd", "/tmp", "--no-focus")
        created.append(result["workspace"]["workspace_id"])
        if len(created) == 1:
            first_tab = result["tab"]["tab_id"]
    a, b = created
    herdr("workspace", "focus", a)
    time.sleep(.3)
    exercise("split_vertical", "prefix+v")
    exercise("focus_pane_left", "ctrl+h")
    exercise("focus_pane_right", "ctrl+l")
    exercise("split_horizontal", "prefix+h")
    exercise("focus_pane_up", "ctrl+k")
    exercise("focus_pane_down", "ctrl+j")
    exercise("zoom", "prefix+z")
    exercise("zoom", "prefix+z")
    second = herdr("tab", "create", "--workspace", a, "--label", "test-2", "--cwd", "/tmp", "--no-focus")
    second_tab = second["tab"]["tab_id"]
    exercise("next_tab", "alt+l")
    exercise("next_tab", "alt+l")  # wrap, both tabs are ours
    exercise("previous_tab", "alt+h")
    exercise("switch_tab", "prefix+1")
    exercise("next_workspace", "alt+j")
    exercise("previous_workspace", "alt+k")

    # Regression: task starts in tab 1, user prepares the action in tab 2.
    assert ipc("startWorkflowTask", "herdr:focus_pane_left:ctrl+h")
    wait(lambda s: s["herdrBaselineReady"])
    herdr("tab", "focus", second_tab)
    press("prefix+v")
    time.sleep(.35)
    assert ipc("status")["correct"] == 0
    press("ctrl+h")
    wait(lambda s: s["correct"] == 1 and s["result"] == 1)
    ipc("stopWorkflow")
    print("PASS changed tab/layout after task start", flush=True)

    # Real randomized succession, no reset between successful tasks.
    ipc("startWorkflow")
    successes = 0
    for _ in range(100):
        state = wait(lambda s: s["workflow"] and s["task"] and s["result"] == 0)
        task = state["task"]
        if not task["id"].startswith("herdr:"):
            ipc("skipTask")
            continue
        _, action, binding = task["id"].split(":", 2)
        current = snapshot()
        workspace = current["focused_workspace_id"]
        # No workspace shortcut may leave our two disposable workspaces.
        safe = action in ("next_tab", "previous_tab") and workspace == a
        safe |= action.startswith("focus_pane_") and state["herdrTaskPossible"]
        safe |= (workspace, action) in ((a, "next_workspace"), (b, "previous_workspace"))
        if not safe:
            ipc("skipTask")
            continue
        score = state["correct"]
        press(binding)
        result = wait(lambda s: s["correct"] == score+1 and s["result"] == 1)
        successes += 1
        print("PASS succession", successes, action, flush=True)
        if successes == 8:
            break
        generation = result["generation"]
        wait(lambda s: s["generation"] != generation and s["result"] == 0)
        # No extra baseline delay here: act immediately on the next task.
    assert successes == 8
finally:
    ipc("stopWorkflow")
    herdr("tab", "focus", original["focused_tab_id"])
    for workspace in reversed(created):
        herdr("workspace", "close", workspace)
    after = snapshot()
    assert {p["pane_id"] for p in original["panes"]} == {p["pane_id"] for p in after["panes"]}
    assert settings() == original_settings
    print("Original panes and settings preserved; all test resources removed.", flush=True)
