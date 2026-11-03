const fs = require("node:fs");
const vm = require("node:vm");
const assert = require("node:assert/strict");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const m = vm.createContext({});
vm.runInContext(fs.readFileSync(path.join(base, "Model.js"), "utf8"), m);
const bind = {modmask:64,key:"Q",description:"Close window"};
const parse = list => m.fromBinds(JSON.stringify(list));
assert.equal(parse([bind]).length, 1);
assert.equal(parse([bind, bind]).length, 0);
for (const change of [{locked:true},{mouse:true},{release:true},{longPress:true},
  {submap:"resize"},{keycode:99},{modmask:2},{key:"unknown"},{description:"x".repeat(201)}])
  assert.equal(parse([{...bind,...change}]).length, 0);
assert.equal(m.fromBinds("<img src='https://invalid'>").length, 0);
assert.equal(m.fromBinds("{}").length, 0);
const attack = "<img src='https://invalid/tracker'>";
assert.equal(parse([{...bind,description:attack}])[0].description, attack);
const qml = ["BarWidget.qml", "Selection.qml", "CheckRow.qml"]
  .map(file => fs.readFileSync(path.join(base, file), "utf8")).join("\n");
assert.equal((qml.match(/\bText \{/g)||[]).length,
  (qml.match(/textFormat: Text.PlainText/g)||[]).length);
assert.ok(!qml.includes("tooltipText:")); // No dynamic rich-text sink.
assert.match(qml, /ShortcutInhibitor\s*\{[\s\S]*?window: panel[\s\S]*?enabled: panel\.open/);
assert.ok(qml.includes("!shortcutInhibitor.active"));
assert.ok(qml.includes("onCancelled: root.close()"));
assert.ok(m.matches(parse([bind])[0], 81, 0x10000000));
assert.ok(!m.matches(parse([bind])[0], 81, 0x12000000));
assert.ok(!m.matches(parse([bind])[0], 87, 0x10000000));
assert.ok(m.matches({key:m.keyCode("TAB"),mask:65}, 0x01000002, 0x12000000));
assert.ok(m.matches({key:m.keyCode("RETURN"),mask:64}, 0x01000005, 0x10000000));
assert.equal(m.modifierMask(0x1e000000), 77);
assert.ok(m.isModifier(0x01000022));
assert.ok(!m.isModifier(81));
for(let i=0;i<100;i++) assert.notEqual(m.nextIndex(7,3,i/100),3);
assert.equal(m.nextIndex(1,0,.5),0);
const tasks = [
  {id:"a", label:"Super + H", description:"focus left"},
  {id:"b", label:"Super + Q", description:"Close window"},
  {id:"c", label:"Super + Tab", description:"former workspace"},
  {id:"d", label:"Super + Enter", description:"Terminal öffnen/fokussieren"},
  {id:"e", label:"Super + P", description:"Screenshot"}
];
const ids = value => Array.from(value, x => x.id);
assert.deepEqual(ids(m.selectedTasks(tasks,null)), ["a","b","c","d","e"]);
assert.deepEqual(ids(m.selectedTasks(tasks,[])), []);
assert.deepEqual(ids(m.selectedTasks(tasks,["c","missing"])), ["c"]);
assert.equal(m.groupFor(tasks[0]), "windows");
assert.equal(m.groupFor(tasks[2]), "workspaces");
assert.equal(m.groupFor(tasks[3]), "apps");
assert.equal(m.groupFor(tasks[4]), "capture");
assert.equal(m.groupFor({description:"Clipboard manager"}), "clipboard");
assert.equal(m.groupFor({description:"Network"}), "system");
assert.equal(m.groupFor({description:attack}), "other");
assert.deepEqual(Array.from(m.toggleSelection(tasks,[],tasks.slice(0,2))), ["a","b"]);
assert.deepEqual(Array.from(m.toggleSelection(tasks,["a"],tasks.slice(0,2))), ["a","b"]);
assert.deepEqual(Array.from(m.toggleSelection(tasks,["a","b","c"],tasks.slice(0,2))), ["c"]);
assert.deepEqual(Array.from(m.toggleSelection(tasks,null,[tasks[0]])), ["b","c","d","e"]);
const rows = m.selectionRows(tasks,"FOCUS");
assert.equal(rows.length,2);
assert.equal(rows[0].group,"windows");
assert.equal(rows[0].members.length,2); // Group toggle includes hidden matches.
assert.equal(rows[1].task.id,"a");
assert.equal(m.selectionRows(tasks,"not found").length,0);
// Saved IDs survive serialization and exclude shortcuts added later.
const saved = JSON.parse(JSON.stringify(["a","c"]));
assert.deepEqual(ids(m.selectedTasks([...tasks,{id:"new"}],saved)), ["a","c"]);
// All physical number-row bindings, including shifted variants and 0 -> WS10.
for (let n = 0; n < 10; n++) {
  const digit = String((n + 1) % 10);
  for (const [mask, qt] of [[64,0x10000000],[65,0x12000000],[73,0x1a000000]]) {
    const physical = {modmask:mask, key:"", keycode:n+10, description:"Switch to workspace " + (n+1)};
    const task = parse([physical])[0];
    assert.equal(task.label, m.label(mask, digit));
    assert.equal(m.groupFor(task), "workspaces");
    assert.ok(m.matches(task, 33, qt, n+10)); // Shift/layout symbols do not matter.
    assert.ok(!m.matches(task, 33, qt, n+11)); // Wrong physical key for a shifted symbol.
    assert.ok(!m.matches(task, String((n+2)%10).charCodeAt(0), qt, n+10));
    assert.ok(!m.matches(task, digit.charCodeAt(0), qt ^ 0x04000000, n+10));
    assert.ok(m.matches(task, digit.charCodeAt(0), qt)); // Generated virtual keymap.
    assert.ok(!m.matches(task, digit.charCodeAt(0), qt | 0x20000000, n+10)); // Not numpad.
    assert.equal(parse([physical, {modmask:mask, key:digit, description:"Duplicate"}]).length, 0);
  }
}
for (const keycode of [9,20,-1,"10",10.5])
  assert.equal(parse([{modmask:64,key:"",keycode,description:"Unsupported"}]).length,0);
// Live workflows must only include direct workspace switches.
assert.equal(m.workspaceTarget({description:"Switch to workspace 3"}),3);
assert.equal(m.workspaceTarget({dispatcher:"workspace",arg:"10",description:"custom"}),10);
for (const description of ["Move window to workspace 3","Move window silently to workspace 3",
  "Former workspace","Switch to workspace -1", "Switch to workspace 0", attack])
  assert.equal(m.workspaceTarget({description}),0);
assert.equal(m.workspaceTarget({dispatcher:"workspace",arg:"+1"}),0);
const live = [{workspaceId:1,id:"one"},{workspaceId:2,id:"two"},{workspaceId:0,id:"move"}];
assert.equal(m.workspaceTasks(live).length,2);
for (let i=0;i<100;i++) assert.equal(m.nextWorkspaceTask(live,1,i/100).workspaceId,2);
assert.equal(m.nextWorkspaceTask([live[0]],1,.5),null);
assert.ok(m.workspaceMatches({workspaceId:2,workspaceSlot:true},12));
assert.ok(!m.workspaceMatches({workspaceId:2,workspaceSlot:true},13));
assert.ok(!m.workspaceMatches({workspaceId:2},12));
assert.ok(!m.workspaceMatches({workspaceId:2,workspaceSlot:true},-1));
const slot = parse([{modmask:64,key:"2",dispatcher:"function: 0x123",
  description:"Switch to workspace 2"}])[0];
assert.ok(slot.workspaceSlot);
assert.equal(m.nextWorkspaceTask([slot],12,.5),null);
assert.ok(qml.includes("if (!flowRunning || !flowTask || flowAdvance.running) return"));
assert.ok(qml.includes("onCurrentWorkspaceIdChanged: observeWorkspace(currentWorkspaceId)"));
// Custom display names: safe plain text, bounded, immutable, persistent.
let names = m.withWorkspaceName({},2,"Terminal");
names = m.withWorkspaceName(names,3,"Spotify");
assert.equal(m.workspaceName(names,2),"Terminal");
assert.equal(m.workspaceName(names,3),"Spotify");
assert.equal(m.workspaceName(names,4),"");
assert.equal(m.workspaceName(JSON.parse(JSON.stringify(names)),2),"Terminal");
assert.equal(m.workspaceName(m.withWorkspaceName(names,2,""),2),"");
assert.equal(m.workspaceName(names,2),"Terminal"); // Original unchanged.
assert.equal(m.withWorkspaceName(names,2,"My ")["2"],"My "); // Spaces while typing.
assert.equal(m.workspaceName(m.withWorkspaceName({},2,"  Terminal  "),2),"Terminal");
assert.equal(m.withWorkspaceName({},2,"x".repeat(90))["2"].length,40);
assert.equal(m.workspaceName(m.withWorkspaceName({},2,attack),2),attack);
assert.equal(Object.keys(m.cleanWorkspaceNames(["bad"])).length,0);
assert.equal(Object.keys(m.cleanWorkspaceNames({"__proto__":"bad","0":"bad","x":"bad","2":42})).length,0);
assert.equal(m.cleanWorkspaceNames({"2":"a\nb"})["2"],"a b");
console.log("All shortcut trainer regression tests passed.");
