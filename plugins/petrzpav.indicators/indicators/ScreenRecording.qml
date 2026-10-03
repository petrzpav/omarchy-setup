import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property bool recording: false
  property bool paused: false

  active: recording
  activeText: paused ? "󰏤" : "󰻂"
  inactiveText: "󰻂"
  activeTooltipText: paused ? "Recording paused (Ctrl+Alt+P to resume)" : "Stop recording"
  inactiveTooltipText: "Screen Recording"

  function refresh() {
    if (!root.bar || statusProc.running) return
    // Exit 0 = recording, 2 = recording but paused (state file written by
    // ~/.local/bin/screenrecord-pause-toggle, keyed by recorder pid), 1 = idle.
    statusProc.command = ["bash", "-c", "pid=$(pgrep -f '^gpu-screen-recorder' | head -1); [[ -z $pid ]] && exit 1; f=\"${XDG_RUNTIME_DIR:-/tmp}/screenrecord-paused\"; [[ -f $f && $(cat \"$f\") == \"$pid\" ]] && exit 2; exit 0"]
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
      root.recording = exitCode === 0 || exitCode === 2
      root.paused = exitCode === 2
    }
  }

  onPressed: function() {
    if (root.bar) {
      root.bar.run(root.recording ? Quickshell.env("HOME") + "/.local/bin/screenrecord-session stop" : "omarchy-menu toggle trigger.capture.screenrecord")
    }
  }
}
