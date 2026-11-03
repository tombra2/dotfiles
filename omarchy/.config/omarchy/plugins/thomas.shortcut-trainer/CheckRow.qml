import QtQuick
import qs.Commons as Commons

// Plugin-owned plain-text checkbox with a mixed state for partially selected groups.
Item {
  id: root
  property string label: ""
  property bool checked: false
  property bool mixed: false
  property bool heading: false
  signal clicked()
  implicitHeight: Math.max(Commons.Style.space(40), labelText.implicitHeight + Commons.Style.space(14))
  activeFocusOnTab: true
  Keys.onSpacePressed: clicked()
  Keys.onReturnPressed: clicked()

  Rectangle {
    anchors.fill: parent
    color: root.activeFocus || mouse.containsMouse ? Commons.Color.accent : Commons.Color.foreground
    opacity: root.activeFocus || mouse.containsMouse ? 0.12 : root.heading ? 0.06 : 0
    radius: Commons.Style.cornerRadius
  }
  Row {
    anchors.fill: parent
    anchors.margins: Commons.Style.space(7)
    spacing: Commons.Style.space(10)
    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: Commons.Style.space(18)
      height: width
      radius: Commons.Style.space(3)
      color: root.checked || root.mixed ? Commons.Color.accent : "transparent"
      border.width: 1
      border.color: Commons.Color.accent
      Text {
        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: root.mixed ? "−" : root.checked ? "✓" : ""
        color: Commons.Color.background
        font.pixelSize: Commons.Style.font.body
      }
    }
    Text {
      id: labelText
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - Commons.Style.space(28)
      textFormat: Text.PlainText
      text: root.label
      wrapMode: Text.Wrap
      color: Commons.Color.popups.text
      font.family: Commons.Style.font.family
      font.pixelSize: Commons.Style.font.body
      font.bold: root.heading
    }
  }
  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: { root.forceActiveFocus(); root.clicked() }
  }
}
