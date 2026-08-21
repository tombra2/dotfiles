import QtQuick
import qs.Ui

BarWidget {
    id: root

    moduleName: "hello.world"

    implicitWidth: label.implicitWidth + 20
    implicitHeight: barSize

    Text {
        id: label
        anchors.centerIn: parent
        text: "Hello World"
        color: root.color
        font.pixelSize: root.font.pixelSize
    }
}
