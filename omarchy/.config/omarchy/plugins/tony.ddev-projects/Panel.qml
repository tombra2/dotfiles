import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Item {
  id: root

  property var anchorItem: null
  property var host: null
  property var bar: null
  property bool opened: false

  property var projects: []
  property var gitDirty: ({})
  property string busyName: ""
  property string pendingAction: ""
  property string errorText: ""
  property bool loaded: false

  property string newSitePath: "~/workspace/"
  property bool creating: false
  property bool createExpanded: false
  property string createStatus: ""
  property string createError: ""
  property string resultUser: ""
  property string resultPassword: ""
  property string searchText: ""

  // Producer-side ceilings: without these, ddev/wp output flows straight
  // into a QML SplitParser, which buffers unbounded until it sees a split
  // marker. A huge project listing or a verbose/hijacked command could
  // otherwise grow the parser's buffer without limit.
  readonly property int maxListBytes: 5 * 1024 * 1024
  readonly property int maxListProjects: 500
  readonly property int maxFieldLength: 200
  // approot is used functionally as a cwd (cd, git -C), not just displayed,
  // so it gets Linux's own PATH_MAX instead of the display-field cap.
  readonly property int maxPathLength: 4096
  readonly property int maxCreateBytes: 10 * 1024 * 1024

  readonly property int runningCount: {
    var n = 0
    for (var i = 0; i < projects.length; i++) if (projects[i].status === "running") n++
    return n
  }
  readonly property int totalCount: projects.length

  // Client-side filter/grouping over the already-capped, already-truncated
  // project list — purely presentational, never touches the producer-side
  // caps in applyListing/listProc.
  readonly property var filteredProjects: {
    var q = root.searchText.trim().toLowerCase()
    if (q === "") return root.projects
    return root.projects.filter(function(p) {
      return p.name.toLowerCase().indexOf(q) !== -1 || p.type.toLowerCase().indexOf(q) !== -1
    })
  }
  readonly property var runningProjects: root.filteredProjects.filter(function(p) { return p.status === "running" })
  readonly property var stoppedProjects: root.filteredProjects.filter(function(p) { return p.status !== "running" })

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  function open() {
    root.opened = true
    reloadProjects()
  }

  function close() {
    root.opened = false
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open()
  }

  function reloadProjects() {
    if (!listProc.running) listProc.running = true
  }

  function truncateField(s) {
    s = String(s)
    return s.length > root.maxFieldLength ? s.slice(0, root.maxFieldLength) : s
  }

  function truncatePath(s) {
    s = String(s)
    return s.length > root.maxPathLength ? s.slice(0, root.maxPathLength) : s
  }

  function applyListing(raw) {
    var list = []
    var overflow = raw.length > root.maxListProjects
    var limit = Math.min(raw.length, root.maxListProjects)
    for (var i = 0; i < limit; i++) {
      var p = raw[i]
      if (!p || !p.name) continue
      list.push({
        name: root.truncateField(p.name),
        type: root.truncateField(p.type || ""),
        status: root.truncateField(p.status || "unknown"),
        path: root.truncateField(p.shortroot || p.approot || ""),
        approot: root.truncatePath(p.approot || ""),
        url: root.truncateField(p.primary_url || p.httpsurl || p.httpurl || ""),
        mailpitUrl: root.truncateField(p.mailpit_https_url || p.mailpit_url || "")
      })
    }
    list.sort(function(a, b) { return a.name < b.name ? -1 : (a.name > b.name ? 1 : 0) })
    root.projects = list
    root.loaded = true
    root.errorText = overflow
      ? ("Showing first " + root.maxListProjects + " of " + raw.length + " projects")
      : ""
    root.checkGitStatus()
  }

  function shQuote(s) {
    return "'" + String(s).replace(/'/g, "'\\''") + "'"
  }

  function expandPath(p) {
    var s = String(p).trim()
    if (s.indexOf("~") === 0) s = Quickshell.env("HOME") + s.slice(1)
    return s.replace(/\/+$/, "")
  }

  function createSite() {
    if (root.creating || root.busyName !== "") return
    root.createExpanded = true
    var path = root.expandPath(root.newSitePath)
    if (path.indexOf("/") !== 0) {
      root.createError = "Enter an absolute path, e.g. ~/Work/my-new-site"
      return
    }
    root.creating = true
    root.createError = ""
    root.resultUser = ""
    root.resultPassword = ""
    root.createStatus = "Setting up " + path + " …"
    var title = root.shQuote(path.split("/").pop())
    var script = [
      "set -e",
      "mkdir -p " + root.shQuote(path),
      "cd " + root.shQuote(path),
      "ddev config --project-type=wordpress --docroot=.",
      "ddev start",
      "ddev wp core download",
      "PRIMARY_URL=$(ddev describe -j | jq -r '.raw.primary_url')",
      "ddev wp core install --url=\"$PRIMARY_URL\" --title=" + title +
        " --admin_user=admin --admin_password=admin --admin_email=admin@example.com"
    ].join(" && ")
    // Cap stdout before it ever reaches QML's SplitParser: fold bounds any
    // single line's length (so the parser never buffers an unterminated
    // line without limit) and head -c rejects output past a hard byte
    // ceiling instead of letting it accumulate indefinitely.
    var capped = "( " + script + " ) | /usr/bin/tr '\\r' '\\n' | /usr/bin/fold -w " +
      root.maxFieldLength + " | /usr/bin/head -c " + root.maxCreateBytes
    createProc.command = ["/usr/bin/timeout", "240", "/usr/bin/bash", "-o", "pipefail", "-c", capped]
    createProc.running = false
    createProc.running = true
  }

  function manualRefresh() {
    root.resultUser = ""
    root.resultPassword = ""
    root.createStatus = ""
    root.createError = ""
    root.reloadProjects()
  }

  function checkGitStatus() {
    var running = root.projects.filter(function(p) { return p.status === "running" && p.approot !== "" })
    if (running.length === 0) { root.gitDirty = {}; return }
    var script = running.map(function(p) {
      return "printf '%s\\t' " + root.shQuote(p.name) +
        "; git -C " + root.shQuote(p.approot) + " status --porcelain 2>/dev/null | head -c1 | wc -c"
    }).join("; ")
    gitCheckProc.command = ["/usr/bin/timeout", "10", "/usr/bin/bash", "-c", script]
    gitCheckProc.running = false
    gitCheckProc.running = true
  }

  function runAction(name, action, args, cwd) {
    if (root.busyName !== "") return
    root.busyName = name
    root.pendingAction = action
    actionProc.command = args
    actionProc.workingDirectory = cwd || ""
    actionProc.running = false
    actionProc.running = true
  }

  function startProject(name) {
    root.runAction(name, "start", ["/usr/bin/timeout", "90", "/usr/bin/ddev", "start", name], "")
  }

  function stopProject(name) {
    root.runAction(name, "stop", ["/usr/bin/timeout", "90", "/usr/bin/ddev", "stop", name], "")
  }

  function openDbAdmin(p) {
    root.runAction(p.name, "dbadmin",
      ["/usr/bin/timeout", "90", "/usr/bin/bash", "-c", "test -f .ddev/commands/host/adminer || ddev add-on get ddev/ddev-adminer --version v1.4.1; ddev adminer"],
      p.approot)
  }

  function launchProject(p) {
    if (p.url) Qt.openUrlExternally(p.url)
  }

  function launchMailpit(p) {
    if (p.mailpitUrl) Qt.openUrlExternally(p.mailpitUrl)
  }

  Process {
    id: listProc
    // head -c rejects listing output past a hard byte ceiling before it
    // ever reaches QML's SplitParser, instead of letting an unbounded
    // local project listing grow the parser's buffer without limit.
    command: ["/usr/bin/timeout", "30", "/usr/bin/bash", "-c",
      "/usr/bin/ddev list --json-output | /usr/bin/head -c " + root.maxListBytes]
    stdout: SplitParser {
      onRead: data => {
        if (data.length >= root.maxListBytes) {
          root.errorText = "Project listing too large to display safely"
          return
        }
        try {
          const obj = JSON.parse(data)
          if (obj && obj.raw) root.applyListing(obj.raw)
        } catch (e) {}
      }
    }
    onExited: function(exitCode) {
      if (exitCode !== 0 && !root.loaded) root.errorText = "Couldn't reach DDEV — is Docker running?"
    }
  }

  Process {
    id: actionProc
    onExited: function(exitCode) {
      if (exitCode !== 0) root.errorText = "ddev " + root.pendingAction + " failed for " + root.busyName
      root.busyName = ""
      root.pendingAction = ""
      root.reloadProjects()
    }
  }

  Process {
    id: createProc
    stdout: SplitParser {
      onRead: data => { root.createStatus = root.truncateField(data) }
    }
    onExited: function(exitCode) {
      root.creating = false
      if (exitCode !== 0) {
        root.createError = "Site creation failed (exit " + exitCode + "). Check the path/name and try again."
        root.createStatus = ""
      } else {
        root.createStatus = "Site created successfully."
        root.resultUser = "admin"
        root.resultPassword = "admin"
        root.newSitePath = "~/Work/"
        root.reloadProjects()
      }
    }
  }

  // Same belt-and-suspenders reasoning as the busyName watchdog above —
  // "creating" is a separate flag (the site doesn't exist as a project row
  // yet) so it needs its own guard against a hang the timeout wrapper missed.
  Timer {
    interval: 250000
    repeat: false
    running: root.creating
    onTriggered: {
      root.createError = "Site creation timed out."
      root.createStatus = ""
      root.creating = false
    }
  }

  // One combined "name<TAB>0-or-1" line per running project — cheaper than
  // spawning a separate git process per row, and skips stopped projects
  // since there's nothing actionable to warn about there.
  Process {
    id: gitCheckProc
    stdout: SplitParser {
      onRead: data => {
        var parts = data.split("\t")
        if (parts.length !== 2) return
        var dirty = JSON.parse(JSON.stringify(root.gitDirty))
        dirty[parts[0]] = parseInt(parts[1], 10) > 0
        root.gitDirty = dirty
      }
    }
  }

  Timer {
    interval: 4000
    repeat: true
    running: root.opened
    onTriggered: root.reloadProjects()
  }

  // Belt-and-suspenders: if a spawned action's exit somehow never reaches
  // actionProc.onExited (a hang the "timeout" wrapper missed, or a
  // Process/quickshell hiccup), this guarantees busyName always clears
  // instead of permanently disabling every button in the panel.
  Timer {
    interval: 100000
    repeat: false
    running: root.busyName !== ""
    onTriggered: {
      root.errorText = "'" + root.pendingAction + "' timed out for " + root.busyName
      root.busyName = ""
      root.pendingAction = ""
      root.reloadProjects()
    }
  }

  KeyboardPanel {
    id: popupPanel
    anchorItem: root.anchorItem
    owner: root.host || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: popupPanel.fittedContentWidth(Style.space(420))
    contentHeight: popupPanel.fittedContentHeight(column.implicitHeight, Style.space(560))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()

      Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        Column {
          id: column
          width: parent.width
          spacing: Style.space(10)

          PanelHero {
            title: "DDEV Projects"
            meta: root.totalCount === 0 ? "" : (root.runningCount + " of " + root.totalCount + " running")
            foreground: root.foreground
            fontFamily: root.fontFamily
            iconComponent: Component {
              Text {
                text: ""
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
              }
            }
            trailingControl: Component {
              PanelActionButton {
                iconText: "↻"
                tooltipText: "Refresh"
                foreground: root.foreground
                onClicked: root.manualRefresh()
              }
            }
          }

          Rectangle {
            width: parent.width
            implicitHeight: newSiteColumn.implicitHeight + Style.space(20)
            height: implicitHeight
            radius: Style.cornerRadius
            color: Util.alpha(root.foreground, 0.04)
            border.color: Util.alpha(root.foreground, 0.15)
            border.width: 1

            Column {
              id: newSiteColumn
              anchors.fill: parent
              anchors.margins: Style.space(10)
              spacing: Style.space(8)

              MouseArea {
                width: parent.width
                height: newSiteHeader.implicitHeight
                cursorShape: Qt.PointingHandCursor
                onClicked: root.createExpanded = !root.createExpanded

                Row {
                  id: newSiteHeader
                  width: parent.width
                  spacing: Style.space(6)

                  Text {
                    text: root.createExpanded ? "▾" : "▸"
                    color: Util.alpha(root.foreground, 0.6)
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                  }

                  Text {
                    text: "New WordPress Site"
                    font.bold: true
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                  }
                }
              }

              // Collapsed by default so opening the panel doesn't spend
              // space on site creation before the more common status
              // glance / start / stop. createSite() forces this open so
              // progress and results are never hidden mid-flow.
              Item {
                id: newSiteBody
                width: parent.width
                clip: true
                visible: height > 0
                height: root.createExpanded ? newSiteBodyColumn.implicitHeight : 0
                opacity: root.createExpanded ? 1 : 0

                Behavior on height {
                  NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                  NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                }

                Column {
                  id: newSiteBodyColumn
                  width: parent.width
                  spacing: Style.space(8)

                  Row {
                    width: parent.width
                    spacing: Style.space(8)

                    TextField {
                      id: pathField
                      width: parent.width - createBtn.width - Style.space(8)
                      text: root.newSitePath
                      placeholderText: "~/Work/my-new-site"
                      enabled: !root.creating
                      onTextChanged: root.newSitePath = text
                      onAccepted: root.createSite()
                    }

                    Button {
                      id: createBtn
                      text: root.creating ? "Creating…" : "Create"
                      bordered: true
                      foreground: root.foreground
                      iconText: root.creating ? "↻" : "+"
                      iconSpinning: root.creating
                      enabled: !root.creating && root.busyName === ""
                      onClicked: root.createSite()
                    }
                  }

                  Text {
                    visible: root.createStatus !== ""
                    text: root.createStatus
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: Util.alpha(root.foreground, 0.75)
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                  }

                  Text {
                    visible: root.createError !== ""
                    text: root.createError
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: Color.urgent
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                  }

                  Column {
                    visible: root.resultPassword !== ""
                    width: parent.width
                    spacing: Style.space(2)

                    Text {
                      text: "User: " + root.resultUser
                      color: root.foreground
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.caption
                    }

                    Text {
                      text: "Password: " + root.resultPassword
                      color: root.foreground
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.caption
                    }
                  }
                }
              }
            }
          }

          TextField {
            id: searchField
            visible: root.totalCount > 6
            width: parent.width
            text: root.searchText
            placeholderText: "Filter projects…"
            onTextChanged: root.searchText = text
          }

          Text {
            visible: root.errorText !== ""
            width: parent.width
            text: root.errorText
            color: Color.urgent
            wrapMode: Text.WordWrap
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
          }

          Text {
            visible: root.loaded && root.totalCount === 0 && root.errorText === ""
            width: parent.width
            topPadding: Style.space(20)
            bottomPadding: Style.space(20)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: "No DDEV projects found.\nRun ddev start inside a project to see it here."
            color: Util.alpha(root.foreground, 0.7)
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
          }

          Text {
            visible: root.totalCount > 0 && root.filteredProjects.length === 0
            width: parent.width
            topPadding: Style.space(20)
            bottomPadding: Style.space(20)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: "No projects match “" + root.searchText + "”."
            color: Util.alpha(root.foreground, 0.7)
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
          }

          PanelSectionHeader {
            visible: root.runningProjects.length > 0 && root.stoppedProjects.length > 0
            width: parent.width
            text: "Running — " + root.runningProjects.length
            foreground: root.foreground
            fontFamily: root.fontFamily
          }

          Repeater {
            model: root.runningProjects
            delegate: projectCardDelegate
          }

          PanelSectionHeader {
            visible: root.stoppedProjects.length > 0 && root.runningProjects.length > 0
            width: parent.width
            text: "Stopped — " + root.stoppedProjects.length
            foreground: root.foreground
            fontFamily: root.fontFamily
          }

          Repeater {
            model: root.stoppedProjects
            delegate: projectCardDelegate
          }
        }
      }
    }
  }

  // Shared by both the Running and Stopped Repeaters above — kept outside
  // the scrolling Column so it isn't laid out itself, just instantiated by
  // each Repeater. `column.width` below still resolves: ids are scoped to
  // the whole file, not just their parent.
  Component {
    id: projectCardDelegate

    Rectangle {
      id: card
      required property var modelData
      width: column.width
      implicitHeight: row.implicitHeight + Style.space(16)
      height: implicitHeight
      radius: Style.cornerRadius
      color: Util.alpha(root.foreground, cardHover.hovered ? 0.06 : 0.03)
      border.color: Util.alpha(root.foreground, 0.12)
      border.width: 1

      readonly property bool isRunning: modelData.status === "running"
      readonly property bool isBusy: root.busyName === modelData.name

      HoverHandler { id: cardHover }

      RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: Style.space(8)
        spacing: Style.space(10)

        Rectangle {
          width: Style.space(8)
          height: Style.space(8)
          radius: width / 2
          Layout.alignment: Qt.AlignVCenter
          color: card.isRunning ? Color.accent : Color.muted
        }

        Column {
          Layout.fillWidth: true
          spacing: Style.space(2)

          Row {
            width: parent.width
            spacing: Style.space(6)

            Text {
              text: card.modelData.name
              color: root.foreground
              font.family: root.fontFamily
              font.bold: true
              font.pixelSize: Style.font.subtitle
              elide: Text.ElideRight
              width: Math.min(implicitWidth, parent.width - (dirtyBadge.visible ? dirtyBadge.width + Style.space(6) : 0))
            }

            Text {
              id: dirtyBadge
              visible: root.gitDirty[card.modelData.name] === true
              text: ""
              color: Color.urgent
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              anchors.verticalCenter: parent.verticalCenter

              PanelToolTip {
                visible: dirtyMouse.containsMouse
                text: "Uncommitted changes in this project"
                fontFamily: root.fontFamily
              }
              MouseArea {
                id: dirtyMouse
                anchors.fill: parent
                hoverEnabled: true
              }
            }
          }
          Text {
            text: (card.isBusy
            ? (root.pendingAction === "start" ? "Starting…"
            : root.pendingAction === "stop" ? "Stopping…"
            : "Opening DB Admin (may install & restart)…")
            : (card.modelData.type + " · " + card.modelData.status))
            + (card.modelData.path ? "  ·  " + card.modelData.path : "")
            color: Util.alpha(root.foreground, 0.65)
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
            width: parent.width
          }
        }

        PanelActionButton {
          iconText: "↗"
          tooltipText: "Open in browser"
          foreground: root.foreground
          enabled: card.isRunning && card.modelData.url !== "" && root.busyName === ""
          onClicked: root.launchProject(card.modelData)
        }

        PanelActionButton {
          iconText: ""
          tooltipText: "Open Mailpit (sent emails)"
          foreground: root.foreground
          enabled: card.isRunning && card.modelData.mailpitUrl !== "" && root.busyName === ""
          onClicked: root.launchMailpit(card.modelData)
        }

        PanelActionButton {
          iconText: ""
          tooltipText: "Open DB Admin (Adminer) — installs and restarts the project on first use"
          foreground: root.foreground
          enabled: card.isRunning && root.busyName === ""
          onClicked: root.openDbAdmin(card.modelData)
        }

        PanelActionButton {
          iconText: card.isBusy ? "…" : (card.isRunning ? "■" : "▶")
          tooltipText: card.isRunning ? "Stop" : "Start"
          foreground: root.foreground
          hoverColor: card.isRunning ? Color.urgent : root.foreground
          enabled: !card.isBusy && root.busyName === ""
          onClicked: card.isRunning ? root.stopProject(card.modelData.name) : root.startProject(card.modelData.name)
        }
      }
    }
  }
}


