import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model
import "Herdr.js" as Herdr

BarWidget {
  id: root
  moduleName: "thomas.shortcut-trainer"

  property var hyprTasks: []
  property var applicationTasks: []
  property bool applicationLoadFailed: false
  readonly property var allTasks: hyprTasks.concat(applicationTasks)
  readonly property var selectedIds: setting("selectedIds", null)
  readonly property var workspaceNames: Model.cleanWorkspaceNames(setting("workspaceNames", {}))
  readonly property var tasks: Model.selectedTasks(allTasks, selectedIds).filter(function(t) { return t.trainable !== false })
  property bool selecting: false
  readonly property var catalog: strings
  onTasksChanged: { advance.stop(); stopWorkspaceFlow(); taskIndex = -1; nextTask() }
  property int taskIndex: -1
  readonly property var task: taskIndex >= 0 && taskIndex < tasks.length ? tasks[taskIndex] : null
  property int result: 0
  property int correct: 0
  property int incorrect: 0
  property bool loadFailed: false
  readonly property bool opened: panel.open
  property bool flowRunning: false
  property var flowTask: null
  property int lastWorkspaceId: -1
  readonly property int currentWorkspaceId: Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace
    ? Hyprland.focusedMonitor.activeWorkspace.id : -1
  readonly property var flowTasks: Model.selectedTasks(allTasks, selectedIds)
  property int flowGeneration: 0
  readonly property alias windowState: windowObserver
  readonly property alias herdrState: herdrObserver
  readonly property string detectorRevision: "herdr-state-v2"
  readonly property bool observesWindows: flowRunning && ["close", "floating", "fullscreen", "focus"].indexOf(Model.verificationKind(flowTask)) >= 0
  // A single live workflow is shared visually across all bar instances.
  readonly property var workflowOwner: {
    var widgets = bar && bar.moduleWidgets ? bar.moduleWidgets(moduleName) : [root]
    for (var i = 0; i < widgets.length; i++)
      if (widgets[i] && widgets[i].flowRunning) return widgets[i]
    return null
  }
  readonly property var displayTask: workflowOwner ? workflowOwner.flowTask : task
  readonly property int displayResult: workflowOwner ? workflowOwner.result : result
  readonly property color resultColor: displayResult > 0 ? "#62c777" : displayResult < 0 ? "#ef6262" : Commons.Color.muted
  onCurrentWorkspaceIdChanged: observeWorkspace(currentWorkspaceId)

  implicitWidth: barButtons.implicitWidth
  implicitHeight: barButtons.implicitHeight

  Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  function nextTask() {
    taskIndex = Model.nextIndex(tasks.length, taskIndex, Math.random())
    result = 0
  }
  function open() {
    if (workflowOwner) workflowOwner.stopWorkspaceFlow()
    selecting = !Array.isArray(selectedIds) || tasks.length === 0
    panel.open = true
    result = 0
    loadFailed = false
    if (!bindings.running) bindings.running = true
    if (!appCatalog.running) appCatalog.running = true
  }
  function saveSetting(key, value) {
    var entry = { id: moduleName }
    for (var name in settings) if (name !== "id") entry[name] = settings[name]
    entry[key] = value
    settings = entry
    if (bar && bar.shell && typeof bar.shell.updateEntryInline === "function")
      bar.shell.updateEntryInline(moduleName, entry)
  }
  function saveSelection(ids) { saveSetting("selectedIds", ids) }
  function saveWorkspaceName(workspaceId, name) {
    saveSetting("workspaceNames", Model.withWorkspaceName(workspaceNames, workspaceId, name))
  }
  function editSelection() {
    advance.stop()
    selecting = true
  }
  function startTraining() {
    if (!tasks.length || bindings.running || loadFailed) return
    // Materialize the default all-selection so new bindings do not silently
    // enter an explicitly chosen training set later.
    if (!Array.isArray(selectedIds)) saveSelection(tasks.map(function(t) { return t.id }))
    selecting = false
    nextTask()
    body.forceActiveFocus()
  }
  function close() {
    panel.open = false
    advance.stop()
    stopWorkspaceFlow()
  }
  function stopWorkspaceFlow() {
    flowRunning = false
    flowAdvance.stop()
    flowGeneration++
    flowTask = null
  }
  function setFlowTask(next) {
    flowAdvance.stop()
    flowGeneration++
    flowTask = next
    result = 0
    if (!flowTask) stopWorkspaceFlow()
  }
  function chooseInitialTask() {
    if (flowRunning && !flowTask && windowObserver.settled && herdrObserver.settled) chooseFlowTask()
  }
  function chooseFlowTask() {
    setFlowTask(Model.nextFlowTask(flowTasks, currentWorkspaceId,
      flowTask ? flowTask.id : "", Math.random(), herdrObserver.latest))
  }
  function completeFlowTask() {
    if (!flowRunning || !flowTask || flowAdvance.running) return
    result = 1
    correct++
    flowAdvance.restart()
  }
  function skipFlowTask() {
    if (!flowRunning) return
    flowAdvance.stop()
    chooseFlowTask()
  }
  function startWorkspaceFlow(explicitTask) {
    if (bindings.running || appCatalog.running || loadFailed || (!explicitTask && !flowTasks.length)) return false
    var widgets = bar && bar.moduleWidgets ? bar.moduleWidgets(moduleName) : [root]
    for (var i = 0; i < widgets.length; i++) if (widgets[i]) widgets[i].close()
    correct = 0
    incorrect = 0
    lastWorkspaceId = currentWorkspaceId
    flowGeneration++
    // Random selection waits for current context; explicit diagnostics can name any task.
    flowTask = explicitTask || null
    flowRunning = true
    return true
  }
  function observeWorkspace(id) {
    if (id < 1 || id === lastWorkspaceId) return
    lastWorkspaceId = id
    if (!flowRunning || !flowTask || flowAdvance.running) return
    if (Model.verificationKind(flowTask) !== "workspace") return
    if (Model.workspaceMatches(flowTask, id)) {
      completeFlowTask()
    } else {
      result = -1
      incorrect++
    }
  }
  function acceptKey(event) {
    event.accepted = true
    if (event.isAutoRepeat || !panel.open) return
    if (event.key === Qt.Key_Escape && Model.modifierMask(event.modifiers) === 0) {
      close()
      return
    }
    if (selecting || !shortcutInhibitor.active || Model.isModifier(event.key) || !task || bindings.running || advance.running) return
    if (Model.matches(task, event.key, event.modifiers, event.nativeScanCode)) {
      result = 1
      correct++
      advance.restart()
    } else {
      result = -1
      incorrect++
    }
  }

  Component.onCompleted: { bindings.running = true; appCatalog.running = true }

  // Exclusive focus only focuses the surface. The Wayland inhibitor is what
  // asks Hyprland to deliver compositor shortcut chords to this window.
  ShortcutInhibitor {
    id: shortcutInhibitor
    window: panel
    enabled: panel.open
    onCancelled: root.close()
  }

  // Diagnostics and explicit start/stop commands; no input injection or logging.
  Commons.ShellIpc {
    target: "thomas.shortcut-trainer"
    function status(): string {
      var trainer = root.workflowOwner || root
      return JSON.stringify({opened: root.opened, selecting: root.selecting,
        inhibited: shortcutInhibitor.active, task: trainer.flowRunning ? trainer.flowTask : root.task,
        workflow: trainer.flowRunning, workspace: root.currentWorkspaceId,
        revision: root.detectorRevision,
        verification: Herdr.observable(trainer.flowTask) ? "herdr:" + Herdr.action(trainer.flowTask) : Model.verificationKind(trainer.flowTask),
        herdrAvailable: trainer.herdrState.available, herdrSnapshots: trainer.herdrState.samples,
        herdrExitCode: trainer.herdrState.lastExitCode, herdrOutputBytes: trainer.herdrState.outputBytes,
        herdrBaselineReady: !!trainer.herdrState.baseline,
        herdrFocus: trainer.herdrState.baseline ? trainer.herdrState.baseline.focused : "",
        herdrTaskPossible: Herdr.canPerform(trainer.flowTask, trainer.herdrState.baseline),
        baselineReady: !!trainer.windowState.baseline,
        baselineFocused: trainer.windowState.baseline ? trainer.windowState.baseline.focused : "",
        latestFocused: trainer.windowState.latest ? trainer.windowState.latest.focused : "",
        snapshots: trainer.windowState.samples, generation: trainer.flowGeneration,
        available: root.allTasks.length, selected: root.flowTasks.length,
        applicationShortcuts: root.applicationTasks.length, applicationLoadFailed: root.applicationLoadFailed,
        hasOwner: !!root.workflowOwner, renderedText: barLabel.text,
        controls: {done: doneButton.mapToGlobal(doneButton.width / 2, doneButton.height / 2),
          next: skipButton.mapToGlobal(skipButton.width / 2, skipButton.height / 2)},
        displayName: Model.workspaceName(root.workspaceNames, (trainer.flowRunning ? trainer.flowTask : root.task || {}).workspaceId),
        result: trainer.result, correct: trainer.correct, incorrect: trainer.incorrect})
    }
    function startWorkspaceFlow(): void { root.startWorkspaceFlow() }
    function startWorkflow(): void { root.startWorkspaceFlow() }
    // Explicit one-task entry point; does not modify the saved selection.
    function startWorkflowTask(id: string): bool {
      var candidates = root.allTasks.filter(function(t) { return t.id === id })
      return candidates.length === 1 && root.startWorkspaceFlow(candidates[0])
    }
    function stopWorkflow(): void { if (root.workflowOwner) root.workflowOwner.stopWorkspaceFlow() }
    function completeTask(): void { if (root.workflowOwner) root.workflowOwner.completeFlowTask() }
    function skipTask(): void { if (root.workflowOwner) root.workflowOwner.skipFlowTask() }
    function stopWorkspaceFlow(): void {
      if (root.workflowOwner) root.workflowOwner.stopWorkspaceFlow()
    }
  }

  Process {
    id: bindings
    command: ["hyprctl", "-j", "binds"]
    stdout: StdioCollector {
      onStreamFinished: {
        root.hyprTasks = Model.workflowBinds(text)
      }
    }
    onExited: function(code, status) {
      root.loadFailed = code !== 0 || status !== 0
    }
  }

  Process {
    id: appCatalog
    command: ["python3", Quickshell.env("HOME") + "/.config/omarchy/plugins/thomas.shortcut-trainer/catalog.py"]
    stdout: StdioCollector {
      onStreamFinished: {
        root.applicationTasks = Model.applicationTasks(text)
        try {
          var data = JSON.parse(text)
          root.applicationLoadFailed = !Array.isArray(data.errors) || data.errors.length > 0
        } catch (_) { root.applicationLoadFailed = true }
      }
    }
    onExited: function(code, status) {
      if (code !== 0 || status !== 0) root.applicationLoadFailed = true
    }
  }

  // Both observers remain warm through feedback and task changes. This prevents
  // losing the first action immediately after a new task is displayed.
  StateObserver {
    id: windowObserver
    active: root.flowRunning
    generation: root.flowGeneration
    command: ["timeout", "2s", "hyprctl", "-j", "clients"]
    decode: Model.windowSnapshot
    onSampled: function(snapshot) {
      if (!root.flowTask) { root.chooseInitialTask(); return }
      if (!snapshot || !root.observesWindows || flowAdvance.running) return
      if (baseline && Model.windowOutcome(root.flowTask, baseline, snapshot)) root.completeFlowTask()
    }
  }
  StateObserver {
    id: herdrObserver
    active: root.flowRunning
    generation: root.flowGeneration
    command: ["timeout", "2s", "herdr", "api", "snapshot"]
    decode: Herdr.snapshot
    onSampled: function(snapshot) {
      if (!root.flowTask) { root.chooseInitialTask(); return }
      if (snapshot && !flowAdvance.running && Herdr.outcome(root.flowTask, baseline, snapshot))
        root.completeFlowTask()
      // Herdr actions may be prepared in a different tab/workspace or after a
      // layout change. Compare adjacent real states rather than a stale origin.
      baseline = snapshot
    }
  }

  Timer {
    id: advance
    interval: 850
    onTriggered: if (root.opened) root.nextTask()
  }

  Timer {
    id: flowAdvance
    interval: 850
    onTriggered: root.chooseFlowTask()
  }

  Grid {
    id: barButtons
    columns: root.vertical ? 1 : 3
  WidgetButton {
    id: button
    bar: root.bar
    labelVisible: false
    hasVisualContent: true
    fixedWidth: root.vertical ? root.barSize : barLabel.width + Commons.Style.space(36)
    pressFeedbackButtons: Qt.NoButton
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) {
        if (root.workflowOwner) root.workflowOwner.stopWorkspaceFlow()
        else if (root.opened) root.close()
        else root.open()
      } else if (mouseButton === Qt.RightButton) {
        if (!root.opened) root.open()
        root.editSelection()
      }
    }

    Row {
      anchors.centerIn: parent
      spacing: Commons.Style.space(7)
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: Commons.Style.space(8)
        height: width
        radius: width / 2
        color: root.resultColor
      }
      Text {
        id: barLabel
        visible: !root.vertical
        textFormat: Text.PlainText
        text: (root.displayTask ? Model.workspaceName(root.workspaceNames, root.displayTask.workspaceId) : "") ||
          (root.workflowOwner && root.displayTask
            ? root.displayTask.workspaceId
              ? strings.t("flow.task").arg(Commons.I18n.formatNumber(root.displayTask.workspaceId)).arg(root.displayTask.label)
              : strings.t("flow.action").arg(root.displayTask.description).arg(root.displayTask.label)
            : root.task ? root.task.label : strings.t("title"))
        width: Math.min(implicitWidth, Commons.Style.space(440))
        elide: Text.ElideRight
        color: Commons.Color.bar.text
        font.family: Commons.Style.font.family
        font.pixelSize: Commons.Style.font.body
      }
    }
  }

  WidgetButton {
    id: doneButton
    bar: root.bar
    visible: !!root.workflowOwner
    text: strings.t("flow.done")
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton && root.workflowOwner) root.workflowOwner.completeFlowTask()
    }
  }
  WidgetButton {
    id: skipButton
    bar: root.bar
    visible: !!root.workflowOwner
    text: strings.t("flow.skip")
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton && root.workflowOwner) root.workflowOwner.skipFlowTask()
    }
  }
  }

  KeyboardPanel {
    id: panel
    bar: root.bar
    owner: root
    anchorItem: button
    contentWidth: fittedContentWidth(Commons.Style.space(root.selecting ? 620 : 410))
    contentHeight: fittedContentHeight(body.implicitHeight)
    focusTarget: body
    // Keep focus throughout practice. ShortcutInhibitor above separately
    // suppresses global shortcuts for this surface.
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Column {
      id: body
      width: parent.width
      spacing: Commons.Style.space(12)
      focus: true
      Keys.onPressed: function(event) {
        if (!root.selecting || event.key === Qt.Key_Escape) root.acceptKey(event)
      }
      Keys.onReleased: function(event) { if (!root.selecting) event.accepted = true }

      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: strings.t(root.selecting ? "selection.title" : "title")
        color: Commons.Color.popups.text
        font.family: Commons.Style.font.family
        font.pixelSize: Commons.Style.font.body * 1.2
        font.bold: true
      }
      Button {
        visible: !root.selecting
        text: strings.t("selection.edit")
        // Do not let the button consume training keystrokes after a click.
        focusable: false
        onClicked: root.editSelection()
      }
      Button {
        text: strings.t("flow.start")
        enabled: root.flowTasks.length > 0 && !bindings.running && !appCatalog.running && !root.loadFailed
        focusable: false
        onClicked: root.startWorkspaceFlow()
      }
      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: strings.t("flow.hint") + (root.applicationLoadFailed ? "\n" + strings.t("catalog.error") : "")
        wrapMode: Text.Wrap
        color: Commons.Color.muted
        font.family: Commons.Style.font.family
        font.pixelSize: Commons.Style.font.body
      }
      Selection {
        visible: root.selecting
        width: parent.width
        tasks: root.allTasks
        selectedIds: root.selectedIds
        workspaceNames: root.workspaceNames
        trainingCount: root.tasks.length
        onWorkspaceNameChanged: function(workspaceId, name) { root.saveWorkspaceName(workspaceId, name) }
        strings: root.catalog
        listHeight: Math.max(Commons.Style.space(100), Math.min(Commons.Style.space(340), panel.availableCardHeight - Commons.Style.space(440)))
        onSelectionChanged: function(ids) { root.saveSelection(ids) }
        onStartRequested: root.startTraining()
      }
      Column {
        visible: !root.selecting
        width: parent.width
        spacing: Commons.Style.space(12)
      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: root.loadFailed ? strings.t("error") : bindings.running ? strings.t("loading") :
              root.task ? Model.workspaceName(root.workspaceNames, root.task.workspaceId) || root.task.label : strings.t(root.allTasks.length ? "selection.empty" : "empty")
        wrapMode: Text.Wrap
        color: Commons.Color.popups.text
        font.family: Commons.Style.font.family
        font.pixelSize: Commons.Style.font.body * 1.5
        font.bold: true
      }
      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: root.task ? root.task.description : ""
        wrapMode: Text.Wrap
        color: Commons.Color.popups.text
        font.family: Commons.Style.font.family
        font.pixelSize: Commons.Style.font.body
      }
      Row {
        spacing: Commons.Style.space(8)
        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: Commons.Style.space(10)
          height: width
          radius: width / 2
          color: root.resultColor
        }
        Text {
          textFormat: Text.PlainText
          text: strings.t(!shortcutInhibitor.active ? "capture.unavailable" : root.result > 0 ? "correct" : root.result < 0 ? "wrong" : "ready")
          color: root.resultColor
          font.family: Commons.Style.font.family
          font.pixelSize: Commons.Style.font.body
        }
      }
      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: strings.t("score").arg(Commons.I18n.formatNumber(root.correct)).arg(Commons.I18n.formatNumber(root.incorrect))
        color: Commons.Color.popups.text
        font.family: Commons.Style.font.family
        font.pixelSize: Commons.Style.font.body
      }
      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: strings.t("hint")
        wrapMode: Text.Wrap
        color: Commons.Color.muted
        font.family: Commons.Style.font.family
        font.pixelSize: Commons.Style.font.body
      }
      }
    }
  }
}
