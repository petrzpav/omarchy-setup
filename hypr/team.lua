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

-- Herdr in its own window: focused when open, started when not (default stays on SUPER + CTRL + RETURN)
o.bind("SUPER + SHIFT + H", "Herdr", { tui = "herdr", focus = true })

-- SUPER + W hides the window instead of closing it: the app keeps running, and whatever
-- focuses it again (its launcher, a notification, SUPER + Z, SUPER + ALT + W) puts it back
-- where it was, so reopening is instant. SUPER + Q really closes it.
hl.unbind("SUPER + W")
o.bind("SUPER + W", "Hide window (SUPER + Q closes)", bin .. "app-hide")
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
o.bind("SUPER + Z", "Bring back the last hidden window", bin .. "app-unhide --last")
o.bind("SUPER + ALT + W", "Hidden windows", bin .. "app-unhide")
-- The browser keys open a new window each time, so they bring back a hidden one first.
for _, keys in ipairs({ "SUPER + SHIFT + B", "SUPER + SHIFT + RETURN" }) do
  hl.unbind(keys)
  o.bind(keys, "Browser (brings back a hidden one first)", bin .. "app-unhide --browser")
end
hl.on("window.active", function(window)
  if window and window.workspace and window.workspace.name == "special:hidden" then
    hl.exec_cmd(bin .. "app-unhide --address " .. window.address)
  end
end)
