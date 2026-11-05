"""Read-only application shortcut catalog. Never connects to Herdr or runs actions."""
import json
import os
from pathlib import Path
import re
import subprocess
import tomllib

LIMIT = 2_000_000


def chord(value):
    names = {"ctrl": "Ctrl", "control": "Ctrl", "alt": "Alt", "super": "Super",
             "shift": "Shift", "space": "Space", "enter": "Enter", "return": "Enter",
             "arrow_up": "↑", "up": "↑", "arrow_down": "↓", "down": "↓",
             "arrow_left": "←", "left": "←", "arrow_right": "→", "right": "→",
             "page_up": "Page Up", "page_down": "Page Down", "escape": "Esc"}
    parts = value.split("+")
    if value.endswith("++"):
        parts = parts[:-2] + ["+"]
    return " + ".join(names.get(part.lower(), part.upper()) for part in parts)


def task(source, identity, keys, description):
    return {"id": source + ":" + identity, "source": source, "label": keys[:200],
            "description": description[:200], "trainable": False, "workspaceId": 0}


def ghostty_tasks(raw):
    tasks = []
    # list-keybinds prints effective bindings, including user overrides.
    for line in raw.splitlines()[:1000]:
        match = re.match(r"^keybind\s*=\s*(.+?)=(.+)$", line)
        if not match:
            continue
        keys, action = match.groups()
        if action.startswith("="):  # The equals key: ctrl+==increase_font_size:1
            keys, action = keys + "=", action[1:]
        if action.strip() in ("ignore", "unbind"):
            continue
        # Keep action parameters for an accurate description; never execute them.
        tasks.append(task("ghostty", keys, chord(keys), "Ghostty · " + action.strip()))
    return tasks


def herdr_tasks(raw):
    config = tomllib.loads(raw)
    keys = config.get("keys", {})
    if not isinstance(keys, dict):
        return []
    prefix = keys.get("prefix")
    tasks = []

    def add(action, binding, description):
        if not isinstance(binding, str) or not binding or len(binding) > 160:
            return
        # Herdr's range notation denotes distinct shortcuts, not a literal chord.
        match = re.search(r"([1-9])\.\.([1-9])", binding)
        variants = [binding]
        if match:
            lo, hi = map(int, match.groups())
            variants = [binding[:match.start()] + str(n) + binding[match.end():]
                        for n in range(lo, hi + 1)]
        for value in variants:
            if value.startswith("prefix+"):
                if not isinstance(prefix, str) or not prefix:
                    continue  # Never guess an unknown prefix.
                label = chord(prefix) + " → " + chord(value[len("prefix+"):])
            else:
                label = chord(value)
            tasks.append(task("herdr", action + ":" + value, label, "Herdr · " + description))

    for action, bindings in list(keys.items())[:300]:
        if action == "command":
            continue
        for binding in bindings if isinstance(bindings, list) else [bindings]:
            add(action, binding, action.replace("_", " "))
    commands = keys.get("command", [])
    if isinstance(commands, list):
        for command in commands[:100]:
            if isinstance(command, dict) and isinstance(command.get("key"), str):
                description = command.get("description", "custom command")
                if isinstance(description, str):
                    # Do not read or run the configured command body.
                    add("command", command["key"], description)
    return tasks


def bash_tasks():
    # Reference exercises, explicitly labelled as defaults, not detected overrides.
    defaults = [
        ("ctrl+a", "An den Zeilenanfang"), ("ctrl+e", "Ans Zeilenende"),
        ("alt+b", "Ein Wort zurück"), ("alt+f", "Ein Wort vorwärts"),
        ("ctrl+u", "Bis zum Zeilenanfang löschen"), ("ctrl+k", "Bis zum Zeilenende löschen"),
        ("ctrl+w", "Vorheriges Wort löschen"), ("alt+backspace", "Vorheriges Wort löschen"),
        ("ctrl+y", "Gelöschten Text einsetzen"), ("ctrl+r", "Befehlsverlauf rückwärts suchen"),
        ("ctrl+p", "Vorheriger Befehl"), ("ctrl+n", "Nächster Befehl"),
        ("ctrl+l", "Terminalanzeige leeren"), ("ctrl+c", "Vordergrundprozess abbrechen"),
        ("ctrl+d", "EOF senden / leere Shell schließen"), ("tab", "Vervollständigen"),
    ]
    return [task("bash", keys, chord(keys), "Bash (Emacs-Standard) · " + description)
            for keys, description in defaults]


def catalog():
    tasks, errors = bash_tasks(), []
    try:
        result = subprocess.run(["ghostty", "+list-keybinds"], capture_output=True,
                                text=True, timeout=6, check=True)
        if len(result.stdout) > LIMIT:
            raise ValueError("Ghostty output too large")
        tasks.extend(ghostty_tasks(result.stdout))
    except (OSError, ValueError, subprocess.SubprocessError):
        errors.append("ghostty")
    try:
        base = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
        path = base / "herdr" / "config.toml"
        if path.stat().st_size > LIMIT:
            raise ValueError("Herdr config too large")
        tasks.extend(herdr_tasks(path.read_text()))
    except (OSError, ValueError, TypeError):
        errors.append("herdr")
    unique = {t["id"]: t for t in tasks}
    return {"tasks": list(unique.values())[:1000], "errors": errors}


if __name__ == "__main__":
    print(json.dumps(catalog(), ensure_ascii=False))
