const fs = require("node:fs");
const assert = require("node:assert/strict");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const m = require('./load.cjs')('Model.js');
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
// All described live bindings, without weakening isolated keyboard capture.
const media = {...bind,key:"XF86AudioRaiseVolume",locked:true,description:"Volume up"};
const mouse = {...bind,key:"mouse:272",mouse:true,description:"Resize window"};
const release = {...bind,release:true,description:"Clipboard manager"};
const submap = {...bind,submap:"resize"};
const catalog = m.workflowBinds(JSON.stringify([bind,media,mouse,release,submap]));
assert.equal(catalog.length,5);
assert.equal(catalog[0].id,parse([bind])[0].id); // Existing saved selection retained.
assert.equal(catalog[0].trainable,true);
for (const task of catalog.slice(1)) assert.equal(task.trainable,false);
assert.equal(new Set(catalog.map(t=>t.id)).size,5);
assert.equal(m.workflowBinds("oops").length,0);
assert.equal(m.workflowBinds("{}").length,0);
assert.equal(m.workflowBinds(null).length,0);
assert.equal(m.workflowBinds(JSON.stringify([{...bind,description:attack}]))[0].description,attack);
const duplicateCatalog = m.workflowBinds(JSON.stringify([bind,bind]));
assert.equal(duplicateCatalog.length,2);
assert.notEqual(duplicateCatalog[0].id,duplicateCatalog[1].id);
assert.equal(duplicateCatalog[0].trainable,false);
const mixedFlow = [{id:"ws",workspaceId:2},{id:"app",description:"Terminal"}];
assert.equal(m.nextFlowTask(mixedFlow,2,"",0).id,"app");
assert.equal(m.nextFlowTask(mixedFlow,1,"ws",0).id,"app");
assert.equal(m.nextFlowTask([mixedFlow[1]],1,"app",0).id,"app");
assert.equal(m.nextFlowTask([],1,"",0),null);
const snapshot = (floating=false,fullscreen=0) => m.windowSnapshot(JSON.stringify([
  {address:"0x123",floating,fullscreen,focusHistoryID:0,title:attack}
]));
const initial = snapshot();
assert.equal(initial.focused,"0x123");
assert.equal(initial.clients["0x123"].title,undefined);
assert.equal(m.verificationKind({description:"Terminal"}),"manual");
assert.equal(m.verificationKind({description:"Close all windows"}),"manual");
assert.ok(m.windowOutcome({description:"Close window"},initial,m.windowSnapshot("[]")));
assert.ok(!m.windowOutcome({description:"Close window"},initial,null));
assert.ok(!m.windowOutcome({description:"Close window"},initial,initial));
assert.ok(!m.windowOutcome({description:"Close window"},m.windowSnapshot("[]"),initial));
assert.ok(m.windowOutcome({description:"Toggle window floating/tiling"},initial,snapshot(true)));
assert.ok(!m.windowOutcome({description:"Toggle window floating/tiling"},initial,snapshot(false,2)));
assert.ok(m.windowOutcome({description:"Full screen"},initial,snapshot(false,2)));
assert.ok(!m.windowOutcome({description:"Terminal"},initial,snapshot(true,2)));
assert.equal(m.windowSnapshot("oops"),null);
assert.equal(m.windowSnapshot("{}"),null);
assert.equal(m.windowSnapshot("[{}]"),null);
assert.equal(m.windowSnapshot('[{"address":"0x123"}]'),null);
assert.ok(qml.includes('command: ["timeout", "2s", "hyprctl", "-j", "clients"]'));
assert.ok(qml.includes('generation: root.flowGeneration'));
assert.ok(qml.includes('text: strings.t("flow.done")'));
// Directional focus checks: real focus and matching geometry are both required.
assert.equal(m.verificationKind({description:"focus left"}),"focus");
assert.equal(m.focusDirection({description:"Focus on right window"}),"right");
assert.equal(m.focusDirection({description:"Focus on next monitor"}),"");
const geometry = (focused, targetX=400, targetY=0, workspace=2) =>
  m.windowSnapshot(JSON.stringify([
    {address:"0xa",floating:false,fullscreen:0,focusHistoryID:focused==="0xa"?0:1,
      at:[0,0],size:[300,300],workspace:{id:2},monitor:0},
    {address:"0xb",floating:false,fullscreen:0,focusHistoryID:focused==="0xb"?0:1,
      at:[targetX,targetY],size:[300,300],workspace:{id:workspace},monitor:0}
  ]));
assert.ok(m.windowOutcome({description:"focus right"},geometry("0xa"),geometry("0xb")));
assert.ok(m.windowOutcome({description:"focus left"},geometry("0xb"),geometry("0xa")));
assert.ok(m.windowOutcome({description:"focus down"},geometry("0xa",0,400),geometry("0xb",0,400)));
assert.ok(m.windowOutcome({description:"focus up"},geometry("0xb",0,400),geometry("0xa",0,400)));
// Both normal movement and edge wrap are valid effects.
assert.ok(m.windowOutcome({description:"focus left"},geometry("0xa"),geometry("0xb")));
assert.ok(m.windowOutcome({description:"focus right"},geometry("0xb"),geometry("0xa")));
assert.ok(m.windowOutcome({description:"focus up"},geometry("0xa",0,400),geometry("0xb",0,400)));
assert.ok(m.windowOutcome({description:"focus down"},geometry("0xb",0,400),geometry("0xa",0,400)));
assert.equal(m.focusDirection({description:"Focus on above window"}),"up");
assert.equal(m.focusDirection({description:"Focus on below window"}),"down");
const column = (focused, axis=1, extras=[]) => m.windowSnapshot(JSON.stringify(
  [0,400,800].map((p,i)=>({
    address:["0xa","0xb","0xc"][i],floating:false,fullscreen:0,
    focusHistoryID:focused===["0xa","0xb","0xc"][i]?0:1,
    at:axis===1?[0,p]:[p,0],size:[300,300],workspace:{id:2},monitor:0
  })).concat(extras)));
for (const [axis,back,forward] of [[1,"up","down"],[0,"left","right"]]) {
  assert.ok(m.windowOutcome({description:"focus "+back},column("0xa",axis),column("0xc",axis)));
  assert.ok(m.windowOutcome({description:"focus "+forward},column("0xc",axis),column("0xa",axis)));
  // Moving against the requested direction from the middle is not a wrap.
  assert.ok(!m.windowOutcome({description:"focus "+back},column("0xb",axis),column("0xc",axis)));
  assert.ok(!m.windowOutcome({description:"focus "+forward},column("0xb",axis),column("0xa",axis)));
  // From the boundary, only the opposite extreme counts as wrap.
  assert.ok(!m.windowOutcome({description:"focus "+back},column("0xa",axis),column("0xb",axis)));
}
// Hyprland wrap may land diagonally at the opposite edge, not in the same row.
const grid = focused => m.windowSnapshot(JSON.stringify(
  [[0,0],[400,0],[0,400],[400,400]].map((at,i)=>({
    address:["0xa","0xb","0xc","0xd"][i],floating:false,fullscreen:0,
    focusHistoryID:focused===["0xa","0xb","0xc","0xd"][i]?0:1,
    at,size:[300,300],workspace:{id:2},monitor:0
  }))));
assert.ok(m.windowOutcome({description:"focus left"},grid("0xc"),grid("0xb")));
assert.ok(m.windowOutcome({description:"focus right"},grid("0xb"),grid("0xc")));
assert.ok(m.windowOutcome({description:"focus up"},grid("0xa"),grid("0xd")));
assert.ok(m.windowOutcome({description:"focus down"},grid("0xd"),grid("0xa")));
const hiddenTop = {address:"0xd",floating:false,fullscreen:0,focusHistoryID:9,
  at:[0,-400],size:[300,300],workspace:{id:2},monitor:0,hidden:true};
assert.ok(m.windowOutcome({description:"focus up"},column("0xa",1,[hiddenTop]),column("0xc",1,[hiddenTop])));
assert.ok(!m.windowOutcome({description:"focus right"},geometry("0xa"),geometry("0xa")));
assert.ok(!m.windowOutcome({description:"focus right"},geometry("0xa"),geometry("0xb",400,0,3)));
assert.ok(!m.windowOutcome({description:"focus right"},initial,snapshot(true)));
assert.match(qml, /flowAdvance\.stop\(\)\s+chooseFlowTask\(\)/); // Next also works during green feedback.
// Application shortcuts can share a workflow without WM misclassification.
const appInput = {tasks:[
  {id:"herdr:focus_pane_up:ctrl+k",source:"herdr",label:"Ctrl + K",description:"focus up"},
  {id:"bash:ctrl+a",source:"bash",label:"Ctrl + A",description:"Line beginning"},
  {id:"ghostty:ctrl+t",source:"ghostty",label:"Ctrl + T",description:attack}
]};
const appTasks = m.applicationTasks(JSON.stringify(appInput));
assert.equal(appTasks.length,3);
assert.equal(appTasks[2].description,attack);
assert.equal(m.verificationKind(appTasks[0]),"herdr");
assert.equal(m.groupFor(appTasks[0]),"herdr");
assert.equal(m.groupFor(appTasks[1]),"terminal");
assert.equal(m.groupFor(appTasks[2]),"terminal");
assert.ok(appTasks.every(t=>t.trainable===false && t.workspaceId===0));
assert.equal(m.selectionRows(appTasks,"Ctrl + K")[0].group,"herdr");
assert.equal(m.selectionRows(appTasks,"Line beginning")[0].group,"terminal");
assert.equal(m.applicationTasks("invalid").length,0);
assert.equal(m.applicationTasks(JSON.stringify({tasks:[{...appInput.tasks[0],source:"other"}]})).length,0);
assert.equal(m.applicationTasks(JSON.stringify({tasks:[{...appInput.tasks[0],id:"64:75"}]})).length,0);
assert.equal(m.nextFlowTask(appTasks,2,appTasks[0].id,0).id,appTasks[1].id);
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
