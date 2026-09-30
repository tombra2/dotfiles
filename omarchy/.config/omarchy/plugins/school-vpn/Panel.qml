import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Ui

Panel {
  id: root
  moduleName: "thomas.school-vpn"

  property bool connected: false
  property bool busy: false
  readonly property string script: "/home/thomas/.config/omarchy/plugins/school-vpn/vpn-toggle.sh"

  Process {
    id: statusProc
    command: [root.script, "status"]
    stdout: StdioCollector {
      onStreamFinished: root.connected = text.trim() === "up"
    }
  }

  Process {
    id: actionProc
    stdout: StdioCollector {}
    onExited: {
      root.busy = false
      statusProc.running = true
    }
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: statusProc.running = true
  }

  Component.onCompleted: statusProc.running = true

  implicitWidth: label.implicitWidth + 24
  implicitHeight: 32

  Rectangle {
    anchors.fill: parent
    radius: 6
    color: root.connected ? "#244b3b" : "transparent"

    Text {
      id: label
      anchors.centerIn: parent
      text: root.busy ? "VPN …" : (root.connected ? "VPN ON" : "VPN OFF")
      color: root.connected ? "#b8f3cf" : "#b8bec9"
      font.pixelSize: 12
    }

    MouseArea {
      anchors.fill: parent
      enabled: !root.busy
      onClicked: {
        root.busy = true
        actionProc.command = [root.script, root.connected ? "down" : "up"]
        actionProc.running = true
      }
    }
  }
}
