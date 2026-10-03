import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property bool running: false
  property bool connected: false

  active: connected
  activeText: "󰄜"
  inactiveText: "󰄜"
  activeTooltipText: "Phone connected (click to stop remote desktop)"
  inactiveTooltipText: running ? "Remote desktop listening (click to stop)" : "Remote desktop off (click to start)"

  function refresh() {
    if (!root.bar || statusProc.running) return
    // Exit 0 = listening, 2 = phone connected, 1 = off.
    statusProc.command = [Quickshell.env("HOME") + "/.local/bin/remote-desktop", "status"]
    statusProc.running = true
  }

  onBarChanged: refresh()
  Component.onCompleted: refresh()

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
  }

  Process {
    id: statusProc
    onExited: function(exitCode) {
      root.running = exitCode === 0 || exitCode === 2
      root.connected = exitCode === 2
    }
  }

  onPressed: function() {
    if (root.bar) root.bar.run(Quickshell.env("HOME") + "/.local/bin/remote-desktop toggle")
  }
}
