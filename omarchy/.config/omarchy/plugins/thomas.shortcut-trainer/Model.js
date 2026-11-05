.import "Herdr.js" as Herdr

// Pure helpers shared by QML and the regression tests. No commands are executed.
function keyCode(name) {
  var key = String(name || "").toUpperCase()
  if (/^[A-Z0-9]$/.test(key)) return key.charCodeAt(0)
  var named = {
    SPACE: 32, RETURN: 0x01000004, ENTER: 0x01000005,
    TAB: 0x01000001, ESCAPE: 0x01000000, BACKSPACE: 0x01000003,
    DELETE: 0x01000007, INSERT: 0x01000006, HOME: 0x01000010,
    END: 0x01000011, LEFT: 0x01000012, UP: 0x01000013,
    RIGHT: 0x01000014, DOWN: 0x01000015,
    PRIOR: 0x01000016, PAGE_UP: 0x01000016,
    NEXT: 0x01000017, PAGE_DOWN: 0x01000017,
    COMMA: 44, PERIOD: 46, SLASH: 47, GRAVE: 96,
    MINUS: 45, EQUAL: 61, SEMICOLON: 59, APOSTROPHE: 39,
    BRACKETLEFT: 91, BRACKETRIGHT: 93, BACKSLASH: 92
  }
  if (named[key] !== undefined) return named[key]
  if (/^F([1-9]|[12][0-9]|3[0-5])$/.test(key))
    return 0x01000030 + Number(key.slice(1)) - 1
  return 0
}

function label(mask, key) {
  var parts = []
  if (mask & 64) parts.push("Super")
  if (mask & 4) parts.push("Ctrl")
  if (mask & 8) parts.push("Alt")
  if (mask & 1) parts.push("Shift")
  var names = { RETURN: "Enter", SPACE: "Space", ESCAPE: "Esc",
    LEFT: "←", RIGHT: "→", UP: "↑", DOWN: "↓", BACKSPACE: "Backspace",
    TAB: "Tab", DELETE: "Delete", COMMA: ",", PERIOD: ".", SLASH: "/",
    GRAVE: "`" }
  var upper = String(key).toUpperCase()
  parts.push(names[upper] || upper)
  return parts.join(" + ")
}

function fromBinds(raw) {
  if (typeof raw !== "string" || raw.length > 2000000) return []
  var binds
  try { binds = JSON.parse(raw) } catch (_) { return [] }
  if (!Array.isArray(binds)) return []
  var candidates = [], counts = Object.create(null)
  binds.slice(0, 5000).forEach(function(b) {
    if (!b || b.submap || b.mouse || b.release || b.locked || b.longPress ||
        b.catch_all || b.non_consuming || !b.description ||
        typeof b.description !== "string" || b.description.length > 200) return
    var mask = b.modmask
    if (!Number.isInteger(mask) || mask < 0 || (mask & ~77) !== 0) return
    // Hyprland/XKB codes 10..19 are the physical top-row 1..9, 0 keys.
    // Match their native scan codes so Shift and keyboard layouts do not
    // turn the exercise into a symbol (e.g. ! instead of Shift+1).
    var scanCode = b.keycode || 0
    if (scanCode && (!Number.isInteger(scanCode) || scanCode < 10 || scanCode > 19)) return
    var keyName = scanCode ? String((scanCode - 9) % 10) : b.key
    var code = keyCode(keyName)
    if (!code || (code === 0x01000000 && mask === 0)) return
    var id = mask + ":" + code
    counts[id] = (counts[id] || 0) + 1
    candidates.push({id: id, key: code, mask: mask, scanCode: scanCode,
      label: label(mask, keyName), description: b.description,
      workspaceId: workspaceTarget(b),
      workspaceSlot: typeof b.dispatcher === "string" && b.dispatcher !== "workspace" &&
        /^Switch to workspace ([1-9]|10)$/.test(b.description)})
  })
  // Ambiguous duplicate bindings are not useful exercises.
  return candidates.filter(function(b) { return counts[b.id] === 1 }).slice(0, 500)
}

// Live mode also offers bindings that cannot be captured in isolated practice.
// Binding arguments are never executed.
function workflowBinds(raw) {
  if (typeof raw !== "string" || raw.length > 2000000) return []
  var safe = fromBinds(raw), byId = Object.create(null), seen = Object.create(null)
  safe.forEach(function(t) { byId[t.id] = t })
  var binds
  try { binds = JSON.parse(raw) } catch (_) { return [] }
  if (!Array.isArray(binds)) return []
  return binds.slice(0, 5000).filter(function(b) {
    return b && typeof b.description === "string" && b.description.length > 0 &&
      b.description.length <= 200 && Number.isInteger(b.modmask) &&
      typeof b.key === "string" && b.key.length <= 80
  }).map(function(b) {
    var single = fromBinds(JSON.stringify([b]))[0]
    if (single && byId[single.id]) {
      single.trainable = true
      return single
    }
    var key = b.key || ("Code " + b.keycode)
    var id = "live:" + b.modmask + ":" + key + ":" + String(b.submap || "").slice(0, 80) +
      ":" + !!b.release + ":" + !!b.mouse
    var n = seen[id] || 0
    seen[id] = n + 1
    return {id: id + ":" + n, key: 0, mask: b.modmask, trainable: false,
      label: label(b.modmask, key) + (b.release ? " ↑" : "") +
        (b.submap ? " [" + String(b.submap).slice(0, 80) + "]" : ""),
      description: b.description, workspaceId: 0}
  }).slice(0, 500)
}

// App-internal shortcuts are workflow exercises, never window-manager actions.
function applicationTasks(raw) {
  if (typeof raw !== "string" || raw.length > 2000000) return []
  var data
  try { data = JSON.parse(raw) } catch (_) { return [] }
  if (!data || !Array.isArray(data.tasks)) return []
  return data.tasks.slice(0, 1000).filter(function(t) {
    return t && ["herdr", "ghostty", "bash"].indexOf(t.source) >= 0 &&
      typeof t.id === "string" && t.id.indexOf(t.source + ":") === 0 && t.id.length <= 300 &&
      typeof t.label === "string" && t.label.length <= 200 &&
      typeof t.description === "string" && t.description.length <= 200
  }).map(function(t) {
    return {id: t.id, source: t.source, label: t.label, description: t.description,
      trainable: false, workspaceId: 0}
  })
}

function focusDirection(task) {
  var match = /^(?:focus(?: on)? (left|right|up|down|above|below)(?: window)?)$/i.exec(task && task.description || "")
  var direction = match ? match[1].toLowerCase() : ""
  return direction === "above" ? "up" : direction === "below" ? "down" : direction
}

function verificationKind(task) {
  if (Herdr.observable(task)) return "herdr"
  if (!task || task.source) return "manual"
  if (task.workspaceId > 0) return "workspace"
  if (focusDirection(task)) return "focus"
  if (task.description === "Close window") return "close"
  if (task.description === "Toggle window floating/tiling") return "floating"
  if (task.description === "Full screen" || task.description === "Tiled full screen") return "fullscreen"
  return "manual"
}

function nextFlowTask(tasks, currentWorkspace, previousId, random, herdrState) {
  var available = tasks.filter(function(t) {
    return (!t.workspaceId || !workspaceMatches(t, currentWorkspace)) && Herdr.canPerform(t, herdrState)
  })
  var other = available.filter(function(t) { return t.id !== previousId })
  if (other.length) available = other
  return available.length ? available[Math.floor(random * available.length)] : null
}

// Only needed state is retained in memory; no window titles or commands.
function windowSnapshot(raw) {
  if (typeof raw !== "string" || raw.length > 2000000) return null
  var list
  try { list = JSON.parse(raw) } catch (_) { return null }
  if (!Array.isArray(list) || list.length > 5000) return null
  if (list.some(function(c) {
    return !c || typeof c.address !== "string" || !/^0x[0-9a-f]+$/i.test(c.address) ||
      typeof c.floating !== "boolean" || !Number.isInteger(c.fullscreen)
  })) return null
  var clients = Object.create(null), focused = ""
  list.forEach(function(c) {
    if (!c || typeof c.address !== "string" || !/^0x[0-9a-f]+$/i.test(c.address)) return
    clients[c.address] = {floating: c.floating, fullscreen: c.fullscreen,
      at: Array.isArray(c.at) ? c.at.slice(0, 2) : null,
      size: Array.isArray(c.size) ? c.size.slice(0, 2) : null,
      workspace: c.workspace ? c.workspace.id : null, monitor: c.monitor,
      hidden: c.hidden === true || c.mapped === false}
    if (c.focusHistoryID === 0) focused = c.address
  })
  return {clients: clients, focused: focused}
}

// At a boundary the compositor may wrap to the opposite end of the row/column.
// Use pre-action geometry so viewport scrolling cannot move the boundary.
function focusWraps(direction, before, after) {
  var old = before.clients[before.focused]
  var axis = direction === "left" || direction === "right" ? 0 : 1
  var sign = direction === "left" || direction === "up" ? -1 : 1
  function valid(c) {
    return c && !c.hidden && c.workspace === old.workspace && c.monitor === old.monitor &&
      Array.isArray(c.at) && Array.isArray(c.size) && c.at.length === 2 && c.size.length === 2 &&
      c.at.concat(c.size).every(function(n) { return typeof n === "number" && isFinite(n) }) &&
      c.size[0] > 0 && c.size[1] > 0
  }
  function position(c) { return sign * (c.at[axis] + c.size[axis] / 2) }
  var target = before.clients[after.focused]
  if (!valid(old) || !valid(target)) return false
  var origin = position(old), destination = position(target), opposite = origin
  var candidates = Object.keys(before.clients).map(function(id) { return before.clients[id] }).filter(valid)
  for (var i = 0; i < candidates.length; i++) {
    var p = position(candidates[i])
    if (p > origin + 1) return false // Not at the requested boundary.
    opposite = Math.min(opposite, p)
  }
  return destination < origin - 1 && Math.abs(destination - opposite) <= 1
}

function windowOutcome(task, before, after) {
  if (!before || !after || !before.focused || !before.clients[before.focused]) return false
  var old = before.clients[before.focused], now = after.clients[before.focused]
  var kind = verificationKind(task)
  if (kind === "focus") {
    var target = after.clients[after.focused]
    if (!target || after.focused === before.focused ||
        old.workspace == null || old.workspace !== target.workspace ||
        old.monitor == null || old.monitor !== target.monitor) return false
    if (!old.at || !old.size || !target.at || !target.size) return false
    var values = old.at.concat(old.size, target.at, target.size)
    if (values.length !== 8 || !values.every(function(n) { return typeof n === "number" && isFinite(n) })) return false
    var dx = target.at[0] + target.size[0] / 2 - old.at[0] - old.size[0] / 2
    var dy = target.at[1] + target.size[1] / 2 - old.at[1] - old.size[1] / 2
    var direction = focusDirection(task)
    var direct = direction === "left" ? dx < -1 : direction === "right" ? dx > 1 :
      direction === "up" ? dy < -1 : dy > 1
    return direct || focusWraps(direction, before, after)
  }
  if (kind === "close") return !now
  if (!now) return false
  if (kind === "floating")
    return typeof old.floating === "boolean" && typeof now.floating === "boolean" &&
      old.floating !== now.floating
  if (kind === "fullscreen")
    return Number.isInteger(old.fullscreen) && Number.isInteger(now.fullscreen) &&
      old.fullscreen !== now.fullscreen
  return false
}

// Only direct, numbered workspace switches. Never infer a destination for
// move-window, relative, scratchpad, or previous-workspace actions.
function workspaceTarget(bind) {
  if (bind.dispatcher === "workspace" && /^[1-9][0-9]{0,5}$/.test(String(bind.arg)))
    return Number(bind.arg)
  var match = /^Switch to workspace ([1-9][0-9]{0,5})$/.exec(bind.description || "")
  return match ? Number(match[1]) : 0
}

// Workspace aliases are plugin-local display labels, never commands or markup.
function cleanWorkspaceNames(value) {
  var names = {}
  if (!value || typeof value !== "object" || Array.isArray(value)) return names
  Object.keys(value).slice(0, 100).forEach(function(key) {
    if (!/^[1-9][0-9]{0,5}$/.test(key) || typeof value[key] !== "string") return
    var name = value[key].replace(/[\u0000-\u001f\u007f-\u009f]/g, " ").slice(0, 40)
    if (name.trim()) names[key] = name
  })
  return names
}

function workspaceName(names, workspaceId) {
  var value = names && names[String(workspaceId)]
  return typeof value === "string" ? value.trim() : ""
}

function withWorkspaceName(names, workspaceId, name) {
  var next = cleanWorkspaceNames(names)
  var key = String(workspaceId)
  if (!/^[1-9][0-9]{0,5}$/.test(key)) return next
  // Keep trailing spaces while typing multi-word names.
  next[key] = String(name).replace(/[\u0000-\u001f\u007f-\u009f]/g, " ").slice(0, 40)
  if (!next[key].trim()) delete next[key]
  return next
}

function workspaceTasks(tasks) {
  return tasks.filter(function(t) { return Number.isInteger(t.workspaceId) && t.workspaceId > 0 })
}

function workspaceMatches(task, workspaceId) {
  if (!task || workspaceId < 1) return false
  // Omarchy Lua bindings use per-monitor blocks of ten workspace slots.
  var actual = task.workspaceSlot ? ((workspaceId - 1) % 10) + 1 : workspaceId
  return actual === task.workspaceId
}

function nextWorkspaceTask(tasks, currentWorkspace, random) {
  var available = workspaceTasks(tasks).filter(function(t) { return !workspaceMatches(t, currentWorkspace) })
  return available.length ? available[Math.floor(random * available.length)] : null
}

// Groups are inferred from active binding descriptions, not executable commands.
function groupFor(task) {
  if (task.source === "herdr") return "herdr"
  if (task.source === "ghostty" || task.source === "bash") return "terminal"
  var d = task.description.toLowerCase()
  if (/workspace|arbeitsfläche|scratchpad|quake/.test(d)) return "workspaces"
  if (/clipboard|copy|paste|cut|select all|zwischenablage/.test(d)) return "clipboard"
  if (/screenshot|capture|screenrecord|ocr|color picker|share|transcode|webcam/.test(d)) return "capture"
  if (/window|focus|fullscreen|full screen|full width|layout|floating|tiling|fenster/.test(d)) return "windows"
  if (/terminal|browser|editor|herdr|tmux|file manager|calculator|music|docker|signal|obsidian|omawrite|chatgpt|grok|calendar|email|youtube|whatsapp|google|password|todoist|agent|^x$|x post/.test(d)) return "apps"
  if (/menu|bar|panel|monitor|display|audio|bluetooth|network|power|lock|theme|background|language|dictation|notification|reminder|time|battery|weather|zoom|transparency|gaps/.test(d)) return "system"
  return "other"
}

function selectedTasks(tasks, ids) {
  if (!Array.isArray(ids)) return tasks
  return tasks.filter(function(t) { return ids.indexOf(t.id) >= 0 })
}

function toggleSelection(tasks, ids, targets) {
  var selected = selectedTasks(tasks, ids).map(function(t) { return t.id })
  var all = targets.every(function(t) { return selected.indexOf(t.id) >= 0 })
  targets.forEach(function(t) {
    var index = selected.indexOf(t.id)
    if (all && index >= 0) selected.splice(index, 1)
    else if (!all && index < 0) selected.push(t.id)
  })
  return selected
}

function selectionRows(tasks, query) {
  var rows = [], q = String(query || "").trim().toLowerCase()
  ;["terminal", "herdr", "windows", "workspaces", "apps", "system", "capture", "clipboard", "other"].forEach(function(group) {
    var members = tasks.filter(function(t) { return groupFor(t) === group })
    var visible = members.filter(function(t) {
      return !q || (t.label + " " + t.description).toLowerCase().indexOf(q) >= 0
    })
    if (!visible.length) return
    rows.push({header: true, group: group, members: members})
    visible.forEach(function(t) { rows.push({header: false, task: t}) })
  })
  return rows
}

function modifierMask(qtModifiers) {
  return ((qtModifiers & 0x10000000) ? 64 : 0) |
         ((qtModifiers & 0x04000000) ? 4 : 0) |
         ((qtModifiers & 0x08000000) ? 8 : 0) |
         ((qtModifiers & 0x02000000) ? 1 : 0)
}

function matches(task, key, modifiers, scanCode) {
  if (task.scanCode) {
    if (modifiers & 0x20000000) return false // Qt.KeypadModifier: not the number row.
    if (modifierMask(modifiers) !== task.mask) return false
    // Virtual keyboards may use a generated keymap with different native
    // codes. Plain digits can be compared directly; shifted/layout symbols
    // still use the physical XKB code from Hyprland.
    if (key >= 48 && key <= 57) return key === task.key
    return scanCode === task.scanCode
  }
  // Shift+Tab arrives as Backtab on Qt.
  if (key === 0x01000002) key = 0x01000001
  if (key === 0x01000005) key = 0x01000004
  var expected = task.key === 0x01000005 ? 0x01000004 : task.key
  return key === expected && modifierMask(modifiers) === task.mask
}

function isModifier(key) {
  return key >= 0x01000020 && key <= 0x01000026
}

function nextIndex(length, current, random) {
  if (length <= 1) return 0
  if (current < 0 || current >= length) return Math.floor(random * length)
  return (current + 1 + Math.floor(random * (length - 1))) % length
}
