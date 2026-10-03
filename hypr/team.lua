-- Shared base config from omarchy-setup. Loaded from ~/.config/hypr/hyprland.lua
-- after Omarchy's defaults and before your own hypr/*.lua files, so anything you
-- set there wins. Don't edit this file: `git pull` and re-run ./install instead.

local bin = os.getenv("HOME") .. "/.local/bin/"

-- Tighter gaps and VS Code-like rounded corners
hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 6,
  },
  decoration = {
    rounding = 6,
  },
})

-- Crash-safe screen recording (focused monitor + microphone, MKV, auto-restart)
o.bind("CTRL + ALT + R", "Start/stop screen recording with mic (crash-safe)", bin .. "screenrecord-session")
o.bind("CTRL + ALT + P", "Pause/resume screen recording", bin .. "screenrecord-pause-toggle")

-- Herdr (default stays on SUPER + CTRL + RETURN)
o.bind("SUPER + SHIFT + H", "Herdr", { omarchy = "terminal-herdr" })
