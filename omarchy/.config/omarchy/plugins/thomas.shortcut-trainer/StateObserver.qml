import QtQuick
import Quickshell.Io

// Shared read-only polling lifecycle. No scoring or application-specific rules.
QtObject {
  id: root
  property bool active: false
  property int generation: 0
  property var command: []
  property var decode: function(raw) { return null }
  property var latest: null
  property var baseline: null
  property int samples: 0
  property int queryGeneration: -1
  property bool available: false
  property bool settled: false
  property int lastExitCode: -1
  property int outputBytes: 0
  signal sampled(var snapshot)

  onGenerationChanged: baseline = latest
  onActiveChanged: {
    latest = null
    baseline = null
    available = false
    settled = false
    if (active) poll()
  }
  function poll() {
    if (!active || process.running) return
    queryGeneration = generation
    process.running = true
  }
  property Process queryProcess: Process {
    id: process
    command: root.command
    property string output: ""
    stdout: StdioCollector { onStreamFinished: process.output = text }
    onStarted: output = ""
    onExited: function(code, status) {
      if (!root.active || root.queryGeneration !== root.generation) return
      var snapshot = code === 0 && status === 0 ? root.decode(output) : null
      root.lastExitCode = code
      root.outputBytes = output.length
      root.samples++
      root.available = !!snapshot
      root.latest = snapshot
      root.settled = true
      if (!snapshot || !root.baseline) root.baseline = snapshot
      root.sampled(snapshot)
    }
  }
  property Timer ticker: Timer {
    interval: 200
    repeat: true
    running: root.active
    onTriggered: root.poll()
  }
}
