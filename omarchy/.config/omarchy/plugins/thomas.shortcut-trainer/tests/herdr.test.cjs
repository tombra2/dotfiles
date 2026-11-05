const fs = require('node:fs');
const assert = require('node:assert/strict');
const path = require('node:path');
const h = require('./load.cjs')('Herdr.js');
const task = a => ({source:'herdr',id:'herdr:'+a+':prefix+2'});
function state(focus='w1:p1', axis='x') {
  const panes={};
  for(let i=0;i<3;i++) panes['w1:p'+(i+1)]={x:axis==='x'?i*100:0,y:axis==='y'?i*100:0,width:100,height:100};
  return {focused:focus,tab:'w1:t1',workspace:'w1',layouts:{'w1:t1':{panes,zoomed:false,splits:[]}},
    tabs:[1,2,3].map(n=>({id:'w1:t'+n,workspace:'w1',number:n})),
    workspaces:[1,2,3].map(n=>({id:'w'+n,number:n}))};
}
for(const [axis,back,forward] of [['x','left','right'],['y','up','down']]) {
 const s=n=>state('w1:p'+n,axis);
 assert.ok(h.outcome(task('focus_pane_'+back),s(1),s(3)));
 assert.ok(h.outcome(task('focus_pane_'+forward),s(3),s(1)));
 assert.ok(h.outcome(task('focus_pane_'+forward),s(1),s(2)));
 assert.ok(!h.outcome(task('focus_pane_'+back),s(2),s(3)));
 assert.ok(!h.outcome(task('focus_pane_'+back),s(1),s(2)));
 assert.ok(!h.outcome(task('focus_pane_'+forward),s(1),s(1)));
}
for(const [action,field,destination] of [['previous_tab','tab','w1:t3'],['next_tab','tab','w1:t2'],['switch_tab','tab','w1:t2'],['previous_workspace','workspace','w3'],['next_workspace','workspace','w2']]) {
 const a=state(), b=state(); b[field]=destination;
 assert.ok(h.outcome(task(action),a,b),action);
 assert.ok(!h.outcome(task(action),a,a));
 b[field]='invalid';assert.ok(!h.outcome(task(action),a,b));
}
const a=state(), b=state();b.layouts[b.tab].zoomed=true;
assert.ok(h.outcome(task('zoom'),a,b));
assert.ok(h.outcome(task('zoom'),b,a));
assert.ok(!h.outcome(task('zoom'),a,a));
for(const [action,direction] of [['split_vertical','right'],['split_horizontal','down']]) {
 const a=state(),b=state();b.layouts[b.tab].panes['w1:p4']={x:0,y:0,width:50,height:50};
 b.layouts[b.tab].splits.push({id:'new',direction});
 assert.ok(h.outcome(task(action),a,b));
 assert.ok(!h.outcome(task(action==='split_vertical'?'split_horizontal':'split_vertical'),a,b));
 b.workspace='w2';assert.ok(!h.outcome(task(action),a,b));
}
for(const action of ['command','prefix','help','rename_tab','resize_mode','copy_mode','new_tab','close_pane']) assert.ok(!h.observable(task(action)));
for(const raw of ['invalid','{}','[]',JSON.stringify({result:{snapshot:{layouts:[],tabs:[],workspaces:[]}}})]) assert.equal(h.snapshot(raw),null);
assert.ok(!h.outcome(task('zoom'),null,state()));
const raw={result:{snapshot:{focused_pane_id:'w1:p1',focused_tab_id:'w1:t1',focused_workspace_id:'w1',
 layouts:[{tab_id:'w1:t1',workspace_id:'w1',zoomed:false,splits:[],panes:[{pane_id:'w1:p1',rect:{x:0,y:0,width:100,height:100}}]}],
 tabs:[{tab_id:'w1:t1',workspace_id:'w1',number:1,label:'private title'}],
 workspaces:[{workspace_id:'w1',number:1,label:'private workspace'}],agents:[{command:'private command'}]}}};
const parsed=h.snapshot(JSON.stringify(raw));
assert.equal(parsed.focused,'w1:p1');
assert.ok(!JSON.stringify(parsed).includes('private'));
// Real IDs are not decimal! This previously disabled the entire detector as
// soon as any workspace/tab/pane counter reached a hexadecimal letter.
const opaque=JSON.stringify(raw).replaceAll('w1:p1','w19A:pB').replaceAll('w1:t1','w19A:tC').replaceAll('"w1"','"w19A"');
assert.equal(h.snapshot(opaque).focused,'w19A:pB');
raw.result.snapshot.layouts[0].panes[0].rect.height=0;
assert.equal(h.snapshot(JSON.stringify(raw)),null);
// A horizontal layout cannot perform up/down. Do not schedule no-op tasks.
assert.ok(!h.canPerform(task('focus_pane_up'),state()));
assert.ok(!h.canPerform(task('focus_pane_down'),state()));
assert.ok(h.canPerform(task('focus_pane_right'),state()));
assert.ok(!h.canPerform(task('focus_pane_left'),state()));
assert.ok(h.canPerform(task('focus_pane_up'),state('w1:p2','y')));
assert.ok(!h.canPerform(task('switch_tab'),{...state(),tab:'w1:t2'}));
const single=state();single.layouts[single.tab].panes={'w1:p1':single.layouts[single.tab].panes['w1:p1']};
assert.ok(!h.canPerform(task('zoom'),single));
// A different row must not prevent wrap in the active row, or offer a fake
// directional action through a diagonal pane.
const rows=state();
rows.layouts[rows.tab].panes['w1:p3']={x:300,y:200,width:100,height:100};
const wrapped=structuredClone(rows);wrapped.focused='w1:p2';
assert.ok(h.outcome(task('focus_pane_left'),rows,wrapped));
assert.ok(!h.canPerform(task('focus_pane_down'),rows));
const model=require('./load.cjs')('Model.js');
const available=[task('focus_pane_up'),task('focus_pane_right')];
assert.equal(model.nextFlowTask(available,1,'',0,state()).id,task('focus_pane_right').id);
for(const t of available.concat([task('help'),task('zoom'),task('command')]))
 assert.equal(model.verificationKind(t)==='herdr',h.observable(t));
const observer=fs.readFileSync(path.join(__dirname,'../StateObserver.qml'),'utf8');
assert.ok(observer.includes('root.queryGeneration !== root.generation'));
assert.ok(observer.includes('code === 0 && status === 0'));
assert.ok(observer.includes('onGenerationChanged: baseline = latest'));
assert.ok(observer.includes('if (!snapshot || !root.baseline) root.baseline = snapshot'));
const qml=fs.readFileSync(path.join(__dirname,'../BarWidget.qml'),'utf8');
assert.ok(qml.includes('baseline = snapshot'));
assert.ok(qml.includes('Herdr.outcome(root.flowTask, baseline, snapshot)'));
console.log('Herdr state tests passed.');
