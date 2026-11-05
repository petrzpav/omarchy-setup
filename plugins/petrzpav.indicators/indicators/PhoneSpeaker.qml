import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property bool connected: false

  active: connected
  activeText: "󰓃"
  inactiveText: "󰓃"
  activeTooltipText: "Sound plays on the phone (click to switch back)"
  inactiveTooltipText: "Phone speaker off (click to play sound on the phone)"

  function refresh() {
    if (!root.bar || statusProc.running) return
    // Exit 0 = connected, 1 = off.
    statusProc.command = [Quickshell.env("HOME") + "/.local/bin/phone-speaker", "status"]
    statusProc.running = true
  }

  onBarChanged: refresh()
  Component.onCompleted: refresh()

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
  }

  // Catches the tunnel dropping on its own (phone asleep, omalauncher closed).
  Timer {
    interval: 10000
    running: !!root.bar
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: statusProc
    onExited: function(exitCode) { root.connected = exitCode === 0 }
  }

  onPressed: function() {
    if (root.bar) root.bar.run(Quickshell.env("HOME") + "/.local/bin/phone-speaker toggle")
  }
}
