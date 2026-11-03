import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model

BarWidget {
  id: root
  moduleName: "thomas.shortcut-trainer"

  property var allTasks: []
  readonly property var selectedIds: setting("selectedIds", null)
  readonly property var workspaceNames: Model.cleanWorkspaceNames(setting("workspaceNames", {}))
  readonly property var tasks: Model.selectedTasks(allTasks, selectedIds)
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
  readonly property var flowTasks: Model.workspaceTasks(tasks)
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

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

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
  }
  function saveSelection(ids) {
    var entry = { id: moduleName }
    for (var key in settings) if (key !== "id") entry[key] = settings[key]
    entry.selectedIds = ids
    settings = entry
    if (bar && bar.shell && typeof bar.shell.updateEntryInline === "function")
      bar.shell.updateEntryInline(moduleName, entry)
  }
  function saveWorkspaceName(workspaceId, name) {
    var entry = { id: moduleName }
    for (var key in settings) if (key !== "id") entry[key] = settings[key]
    entry.workspaceNames = Model.withWorkspaceName(workspaceNames, workspaceId, name)
    settings = entry
    if (bar && bar.shell && typeof bar.shell.updateEntryInline === "function")
      bar.shell.updateEntryInline(moduleName, entry)
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
  }
  function startWorkspaceFlow() {
    if (bindings.running || loadFailed || flowTasks.length < 2 || currentWorkspaceId < 1) return
    var widgets = bar && bar.moduleWidgets ? bar.moduleWidgets(moduleName) : [root]
    for (var i = 0; i < widgets.length; i++) if (widgets[i]) widgets[i].close()
    correct = 0
    incorrect = 0
    lastWorkspaceId = currentWorkspaceId
    flowTask = Model.nextWorkspaceTask(flowTasks, currentWorkspaceId, Math.random())
    result = 0
    flowRunning = !!flowTask
  }
  function observeWorkspace(id) {
    if (id < 1 || id === lastWorkspaceId) return
    lastWorkspaceId = id
    if (!flowRunning || !flowTask || flowAdvance.running) return
    if (Model.workspaceMatches(flowTask, id)) {
      result = 1
      correct++
      flowAdvance.restart()
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

  Component.onCompleted: bindings.running = true

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
        displayName: Model.workspaceName(root.workspaceNames, (trainer.flowRunning ? trainer.flowTask : root.task || {}).workspaceId),
        result: trainer.result, correct: trainer.correct, incorrect: trainer.incorrect})
    }
    function startWorkspaceFlow(): void { root.startWorkspaceFlow() }
    function stopWorkspaceFlow(): void {
      if (root.workflowOwner) root.workflowOwner.stopWorkspaceFlow()
    }
  }

  Process {
    id: bindings
    command: ["hyprctl", "-j", "binds"]
    stdout: StdioCollector {
      onStreamFinished: {
        root.allTasks = Model.fromBinds(text)
      }
    }
    onExited: function(code, status) {
      root.loadFailed = code !== 0 || status !== 0
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
    onTriggered: {
      root.flowTask = Model.nextWorkspaceTask(root.flowTasks, root.currentWorkspaceId, Math.random())
      root.result = 0
      if (!root.flowTask) root.stopWorkspaceFlow()
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    labelVisible: false
    hasVisualContent: true
    fixedWidth: root.vertical ? root.barSize : barLabel.implicitWidth + Commons.Style.space(36)
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
            ? strings.t("flow.task").arg(Commons.I18n.formatNumber(root.displayTask.workspaceId)).arg(root.displayTask.label)
            : root.task ? root.task.label : strings.t("title"))
        color: Commons.Color.bar.text
        font.family: Commons.Style.font.family
        font.pixelSize: Commons.Style.font.body
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
        enabled: root.flowTasks.length >= 2 && !bindings.running && !root.loadFailed && root.currentWorkspaceId > 0
        focusable: false
        onClicked: root.startWorkspaceFlow()
      }
      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: strings.t("flow.hint")
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
