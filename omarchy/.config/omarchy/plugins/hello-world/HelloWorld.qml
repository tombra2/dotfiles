import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
    id: root

    moduleName: "hello.world"
    property bool popupOpen: false
    property string status: "unknown"
    property string ref: ""
    property string pipelineId: ""
    property string pipelineUrl: ""
    property string updatedAt: ""

    readonly property color statusColor: {
        if (status === "success") return "#8ec07c"
        if (status === "failed") return "#fb4934"
        if (status === "running") return "#fabd2f"
        if (status === "pending") return "#83a598"
        if (status === "canceled") return "#928374"
        return "#928374"
    }

    function refresh() {
        if (!pipelineRequest.running) pipelineRequest.running = true
    }

    function updatePipeline(response) {
        try {
            var pipelines = JSON.parse(response)
            if (!pipelines.length) return
            var pipeline = pipelines[0]
            status = pipeline.status || "unknown"
            ref = pipeline.ref || ""
            pipelineId = pipeline.iid ? "#" + pipeline.iid : ""
            pipelineUrl = pipeline.web_url || ""
            updatedAt = pipeline.updated_at || ""
        } catch (error) {
            status = "unknown"
        }
    }

    function close() {
        popupOpen = false
    }

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    Component.onCompleted: refresh()

    Process {
        id: pipelineRequest
        command: ["glab", "api", "--hostname", "akaryon-development.com", "projects/brandner%2Fpaperpipe/pipelines?per_page=1"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.updatePipeline(text)
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    BarIconButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        text: "󰮠"
        foreground: "white"
        useActiveColor: false
        tooltipText: "Paperpipe: " + root.status
        onPressed: function() {
            root.popupOpen = !root.popupOpen
            root.refresh()
        }

        Rectangle {
            width: Style.space(7)
            height: Style.space(7)
            radius: width / 2
            color: root.statusColor
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: Style.space(2)
            anchors.topMargin: Style.space(2)
            border.color: Color.popups.background
            border.width: 1
        }
    }

    PopupCard {
        anchorItem: button
        bar: root.bar
        owner: root
        open: root.popupOpen
        contentWidth: 260
        contentHeight: 104

        Item {
            anchors.fill: parent

            Text {
                id: title
                anchors.left: parent.left
                anchors.top: parent.top
                text: "Paperpipe " + root.pipelineId
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }

            Text {
                anchors.left: parent.left
                anchors.top: title.bottom
                anchors.topMargin: 8
                text: root.status.toUpperCase() + (root.ref ? " · " + root.ref : "")
                color: root.statusColor
                font.pixelSize: 14
            }

            Text {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                text: root.pipelineUrl ? "Klicken zum Öffnen" : "Pipeline wird geladen"
                color: "#bdae93"
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.pipelineUrl !== ""
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.bar.run("xdg-open " + JSON.stringify(root.pipelineUrl))
            }
        }
    }
}
