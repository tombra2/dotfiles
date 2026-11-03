import QtQuick
import QtQuick.Controls as Controls
import qs.Commons as Commons
import qs.Ui as Ui
import "Model.js" as Model

Column {
  id: root
  required property var tasks
  required property var selectedIds
  required property var strings
  property var workspaceNames: ({})
  signal workspaceNameChanged(int workspaceId, string name)
  property real listHeight: Commons.Style.space(340)
  readonly property var selected: Model.selectedTasks(tasks, selectedIds)
  signal selectionChanged(var ids)
  signal startRequested()
  spacing: Commons.Style.space(10)

  function countSelected(members) {
    return Model.selectedTasks(members, selectedIds).length
  }

  Text {
    width: parent.width
    textFormat: Text.PlainText
    text: root.strings.t("selection.hint")
    wrapMode: Text.Wrap
    color: Commons.Color.muted
    font.family: Commons.Style.font.family
    font.pixelSize: Commons.Style.font.body
  }

  Ui.TextField {
    id: search
    width: parent.width
    placeholderText: root.strings.t("selection.search")
    maximumLength: 200
  }

  Row {
    spacing: Commons.Style.space(8)
    Ui.Button {
      text: root.strings.t("selection.all")
      focusable: true
      onClicked: root.selectionChanged(root.tasks.map(function(t) { return t.id }))
    }
    Ui.Button {
      text: root.strings.t("selection.none")
      focusable: true
      onClicked: root.selectionChanged([])
    }
  }

  ListView {
    id: list
    width: parent.width
    height: root.listHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    model: Model.selectionRows(root.tasks, search.text)
    spacing: Commons.Style.space(2)
    Controls.ScrollBar.vertical: Controls.ScrollBar {}
    delegate: Column {
      id: entry
      required property var modelData
      width: list.width - Commons.Style.space(12)
      readonly property var members: modelData.header ? modelData.members : [modelData.task]
      readonly property int selectedCount: root.countSelected(members)
      readonly property int workspaceId: modelData.header ? 0 : modelData.task.workspaceId || 0
      spacing: Commons.Style.space(4)
      CheckRow {
        width: parent.width
        heading: entry.modelData.header
        checked: entry.selectedCount === entry.members.length
        mixed: entry.selectedCount > 0 && entry.selectedCount < entry.members.length
        label: entry.modelData.header
          ? root.strings.t("group." + entry.modelData.group) + " (" +
            Commons.I18n.formatNumber(entry.selectedCount) + "/" + Commons.I18n.formatNumber(entry.members.length) + ")"
          : entry.modelData.task.label + " — " + entry.modelData.task.description
        onClicked: root.selectionChanged(Model.toggleSelection(root.tasks, root.selectedIds, entry.members))
      }
      Ui.TextField {
        visible: entry.workspaceId > 0
        width: parent.width
        maximumLength: 40
        placeholderText: root.strings.t("workspace.name")
        text: root.workspaceNames[String(entry.workspaceId)] || ""
        // Save immediately, including when practice is started without Enter.
        onTextEdited: root.workspaceNameChanged(entry.workspaceId, text)
      }
    }
    Text {
      anchors.centerIn: parent
      width: parent.width
      textFormat: Text.PlainText
      text: root.strings.t("selection.noResults")
      visible: list.count === 0
      wrapMode: Text.Wrap
      color: Commons.Color.muted
      font.pixelSize: Commons.Style.font.body
    }
  }

  Text {
    width: parent.width
    textFormat: Text.PlainText
    text: root.strings.tn("selection.count", root.selected.length).arg(Commons.I18n.formatNumber(root.selected.length))
    color: Commons.Color.popups.text
    font.family: Commons.Style.font.family
    font.pixelSize: Commons.Style.font.body
  }
  Ui.Button {
    width: parent.width
    text: root.strings.t("selection.start")
    enabled: root.selected.length > 0 && root.tasks.length > 0
    opacity: enabled ? 1 : 0.4
    focusable: true
    onClicked: root.startRequested()
  }
}
