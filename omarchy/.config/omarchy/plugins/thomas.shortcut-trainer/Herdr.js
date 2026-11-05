// Read-only state comparison. Never observes or synthesizes keyboard input.
function action(task) {
  if (!task || task.source !== "herdr") return ""
  var match = /^herdr:([^:]+):(.+)$/.exec(task.id || "")
  return match ? match[1] : ""
}
function observable(task) {
  return /^(focus_pane_(left|right|up|down)|split_vertical|split_horizontal|zoom|previous_tab|next_tab|switch_tab|previous_workspace|next_workspace)$/.test(action(task))
}
// Restrict focus candidates to the same row/column. A tall neighboring pane
// must not manufacture an up/down action in a horizontally split tab.
function focusTargets(state, direction) {
  var layout = state && state.layouts[state.tab]
  var origin = layout && layout.panes[state.focused]
  if (!origin || layout.zoomed) return []
  var horizontal = direction === "left" || direction === "right"
  var sign = direction === "left" || direction === "up" ? -1 : 1
  function center(p) { return horizontal ? p.x+p.width/2 : p.y+p.height/2 }
  return Object.keys(layout.panes).filter(function(id) {
    var p = layout.panes[id]
    var overlap = horizontal
      ? Math.min(origin.y+origin.height,p.y+p.height)-Math.max(origin.y,p.y)
      : Math.min(origin.x+origin.width,p.x+p.width)-Math.max(origin.x,p.x)
    return id !== state.focused && overlap > 0 && sign*(center(p)-center(origin)) > 0
  })
}
function canPerform(task, state) {
  if (!observable(task) || !state) return true // Manual/API-unavailable fallback.
  var a = action(task), layout = state.layouts[state.tab]
  if (a.indexOf("focus_pane_") === 0) return focusTargets(state,a.slice(11)).length > 0
  if (a === "zoom") return layout && Object.keys(layout.panes).length > 1
  if (/workspace$/.test(a)) return state.workspaces.length > 1
  if (/^(previous_tab|next_tab|switch_tab)$/.test(a)) {
    var tabs = state.tabs.filter(function(t) { return t.workspace === state.workspace })
    if (a !== "switch_tab") return tabs.length > 1
    var digit = /\+([1-9])$/.exec(task.id)
    return !!digit && tabs.some(function(t) { return t.number === Number(digit[1]) && t.id !== state.tab })
  }
  return true
}
function snapshot(raw) {
  if (typeof raw !== "string" || raw.length > 2000000) return null
  try {
    var s = JSON.parse(raw).result.snapshot
    if (!s || !Array.isArray(s.layouts) || !Array.isArray(s.tabs) || !Array.isArray(s.workspaces) ||
        s.layouts.length > 1000 || s.tabs.length > 1000 || s.workspaces.length > 1000) return null
    var layouts = {}, tabs = [], workspaces = []
    // Public handles are opaque, not decimal counters: w19A / w193:pA
    // are valid installed-CLI responses after enough resources were created.
    function id(v) {
      return typeof v === "string" && v.length <= 100 && /^w[0-9a-z]+(?::[tp][0-9a-z]+)?$/i.test(v)
    }
    if (!id(s.focused_pane_id) || !id(s.focused_tab_id) || !id(s.focused_workspace_id)) return null
    s.layouts.forEach(function(l) {
      if (!id(l.tab_id) || !id(l.workspace_id) || !Array.isArray(l.panes) || l.panes.length > 1000 ||
          !Array.isArray(l.splits) || typeof l.zoomed !== "boolean") throw Error("layout")
      var panes = {}
      l.panes.forEach(function(p) {
        var r = p.rect
        if (!id(p.pane_id) || !r || ![r.x,r.y,r.width,r.height].every(function(n) {
          return typeof n === "number" && isFinite(n)
        }) || r.width <= 0 || r.height <= 0) throw Error("rect")
        panes[p.pane_id] = {x:r.x,y:r.y,width:r.width,height:r.height}
      })
      layouts[l.tab_id] = {workspace:l.workspace_id, panes:panes, zoomed:l.zoomed,
        splits:l.splits.map(function(v) { return {id:v.id,direction:v.direction} })}
    })
    s.tabs.forEach(function(t) {
      if (!id(t.tab_id) || !id(t.workspace_id) || !Number.isInteger(t.number)) throw Error("tab")
      tabs.push({id:t.tab_id,workspace:t.workspace_id,number:t.number})
    })
    s.workspaces.forEach(function(w) {
      if (!id(w.workspace_id) || !Number.isInteger(w.number)) throw Error("workspace")
      workspaces.push({id:w.workspace_id,number:w.number})
    })
    if (!layouts[s.focused_tab_id] || !layouts[s.focused_tab_id].panes[s.focused_pane_id]) return null
    return {focused:s.focused_pane_id,tab:s.focused_tab_id,workspace:s.focused_workspace_id,
      layouts:layouts,tabs:tabs,workspaces:workspaces}
  } catch (_) { return null }
}
function orderedTarget(items, current, sign) {
  var sorted = items.slice().sort(function(a,b) { return a.number-b.number })
  var index = sorted.map(function(v) { return v.id }).indexOf(current)
  return index < 0 || sorted.length < 2 ? "" : sorted[(index+sign+sorted.length)%sorted.length].id
}
function outcome(task, before, after) {
  if (!observable(task) || !before || !after) return false
  var a = action(task), old = before.layouts[before.tab], now = after.layouts[before.tab]
  if (/workspace$/.test(a)) {
    var expected = orderedTarget(before.workspaces,before.workspace,a === "previous_workspace" ? -1 : 1)
    return !!expected && after.workspace !== before.workspace && after.workspace === expected
  }
  if (before.workspace !== after.workspace) return false
  if (/^(previous_tab|next_tab|switch_tab)$/.test(a)) {
    var tabs = before.tabs.filter(function(t) { return t.workspace === before.workspace })
    var target = ""
    if (a === "switch_tab") {
      var digit = /(?:\+)([1-9])$/.exec(task.id)
      if (!digit) return false
      tabs.forEach(function(t) { if (t.number === Number(digit[1])) target = t.id })
    } else target = orderedTarget(tabs,before.tab,a === "previous_tab" ? -1 : 1)
    return !!target && after.tab !== before.tab && after.tab === target
  }
  if (before.tab !== after.tab || !old || !now) return false
  if (a === "zoom") return old.zoomed !== now.zoomed
  if (/^split_/.test(a)) {
    var direction = a === "split_vertical" ? "right" : "down"
    var added = Object.keys(now.panes).filter(function(id) { return !old.panes[id] })
    return added.length === 1 && Object.keys(now.panes).length === Object.keys(old.panes).length+1 &&
      Object.keys(old.panes).every(function(id) { return !!now.panes[id] }) &&
      now.splits.length === old.splits.length+1 &&
      now.splits.filter(function(s) { return s.direction === direction }).length ===
        old.splits.filter(function(s) { return s.direction === direction }).length+1
  }
  if (a.indexOf("focus_pane_") === 0) {
    if (before.focused === after.focused || old.zoomed !== now.zoomed) return false
    var origin = old.panes[before.focused], targetPane = old.panes[after.focused]
    if (!origin || !targetPane || !now.panes[after.focused] ||
        Object.keys(old.panes).sort().join() !== Object.keys(now.panes).sort().join()) return false
    var direction = a.slice(11), horizontal = direction === "left" || direction === "right"
    var sign = direction === "left" || direction === "up" ? -1 : 1
    function position(p) { return sign*(horizontal ? p.x+p.width/2 : p.y+p.height/2) }
    var start = position(origin), end = position(targetPane)
    if (end > start) return focusTargets(before,direction).indexOf(after.focused) >= 0
    var overlap = horizontal
      ? Math.min(origin.y+origin.height,targetPane.y+targetPane.height)-Math.max(origin.y,targetPane.y)
      : Math.min(origin.x+origin.width,targetPane.x+targetPane.width)-Math.max(origin.x,targetPane.x)
    if (overlap <= 0) return false
    var positions = [origin, targetPane].concat(Object.keys(old.panes).filter(function(id) {
      var p = old.panes[id]
      return horizontal
        ? Math.min(origin.y+origin.height,p.y+p.height) > Math.max(origin.y,p.y)
        : Math.min(origin.x+origin.width,p.x+p.width) > Math.max(origin.x,p.x)
    }).map(function(id) { return old.panes[id] })).map(position)
    // A boundary wrap must land at the opposite extreme, not merely anywhere backwards.
    return end < start && Math.max.apply(null,positions) === start && Math.min.apply(null,positions) === end
  }
  return false
}
