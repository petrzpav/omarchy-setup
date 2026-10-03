---
name: setup
description: Finish the omarchy-setup on this machine with the person - restore files and settings from an old backup, monitors, keyboard and touchpad, git identity, lid and locking, automatic backups, optional apps and plugins, and a short tour of the keybindings. Use when invoked as /setup or when asked to finish or redo the Omarchy setup.
---

# Finish the Omarchy setup

`./install` (in this repo) has already applied the shared, machine-independent part:
the Monokai Pro theme, gaps and rounding, keybindings, crash-safe screen recording,
the bar layout, the omapager, wallswap and indicators plugins, and the extra
packages in `packages.txt`. Your job is the
part that depends on this person and this machine.

Load the `omarchy` skill first if it is available; it has the rules for editing
Omarchy config. In short: edit only `~/.config/`, never `/usr/share/omarchy/`;
back up a file before changing it (`cp f f.bak.$(date +%s)`); after any
`~/.config/hypr/` change run `hyprctl reload` and `hyprctl configerrors`.

## How to run the session

- Start with one short message: what is already done and the list of steps below.
- Go one step at a time. For each, say in a sentence what it does, check the
  current state, then propose a concrete change and ask before applying it.
  Accept "skip" for anything. Never batch several changes into one question.
- Prefer detecting over asking: read `hyprctl monitors all`, `hyprctl devices`,
  `localectl`, `git config --global -l` before asking anything.
- Commands that need `sudo` or a password prompt (fingerprint, packages): run
  them in a visible terminal with `omarchy-launch-floating-terminal-with-presentation <cmd>`,
  or ask the person to run `! <cmd>` in this session.
- Don't touch `hypr/team.lua` or anything else in this repo. Per-person changes go
  into the person's own `~/.config/hypr/*.lua`, which override the shared file.
- If something from `./install` failed or looks wrong, fix it, and tell the person
  what happened.

## Steps

1. **Check the install.** `./install --dry-run` should report everything as up to
   date, and `hyprctl configerrors` should be empty. Fix anything that isn't.
   If a package from `packages.txt` failed to install, say which and retry it with
   `omarchy pkg add <name>` in a visible terminal.

2. **Restore from an old backup.** Ask if they have a backup of their previous
   computer they want to bring over (files, keys, app settings, or their whole
   old setup). Do this early: what comes back may already answer later steps.
   Follow "Restore from an old backup" in [backup.md](backup.md).

3. **Monitors** (`~/.config/hypr/monitors.lua`). List outputs with
   `hyprctl monitors all`. For a laptop with an external screen, ask how the screens
   sit (left/right/above) and which is the main one. Suggest a scale from the
   panel's resolution and physical size (shown in `hyprctl monitors all`): about 1
   for 24" 1080p or 27" 1440p, 1.5 for 27" 4K, 1.5–2 for 13–14" 2.8K+ laptop panels.
   Set `omarchy_monitor_scale` / `omarchy_gdk_scale`, or add per-output
   `hl.monitor({...})` lines.

4. **Keyboard and touchpad** (`~/.config/hypr/input.lua`). Show the current layout
   from `hyprctl devices` and `localectl`. Ask for layouts they type in and how to
   switch (e.g. `grp:alts_toggle`), repeat rate, natural scrolling, tap and
   two-finger right-click. The commented examples in `input.lua` show the syntax.

5. **Git identity.** If `git config --global user.name` / `user.email` are empty,
   ask and set them. Offer `gh auth login` if `gh` is installed and not logged in.

6. **Lid and locking.** Omarchy's default is: lock after 5 minutes idle, and
   closing the lid locks and suspends. Some people keep the laptop docked or reach
   it remotely and want it never to lock on its own. Ask which they prefer and
   explain the trade-off (an unlocked, awake machine is open to anyone nearby).
   Manual lock (Super + Ctrl + L) always keeps working.
   - **Idle lock**: `idle.lock` in `~/.config/omarchy/shell.json`, in seconds
     (default 300). Never lock on idle: `2000000` (the shell has no "off"; `0`
     locks immediately, and more than about 24 days overflows the timer).
     `idle.screensaver` (default 150) is separate; ask about it too.
     Super + Ctrl + I toggles idle locking for the current session.
   - **Lid closes the screen only, no lock or suspend** (laptops only, check
     `omarchy-hyprland-monitor-laptop` returns a panel):
     1. copy `extras/lid-switch` to `~/.local/bin/lid-switch`;
     2. in `~/.config/hypr/bindings.lua` add
        ```lua
        hl.unbind("switch:on:Lid Switch")
        hl.unbind("switch:off:Lid Switch")
        o.bind("switch:on:Lid Switch", nil, os.getenv("HOME") .. "/.local/bin/lid-switch close", { locked = true })
        o.bind("switch:off:Lid Switch", nil, os.getenv("HOME") .. "/.local/bin/lid-switch open", { locked = true })
        ```
     3. stop logind from suspending on the lid (needs sudo, so in a visible terminal):
        `/etc/systemd/logind.conf.d/30-lid-ignore.conf` with `[Login]`,
        `HandleLidSwitch=ignore`, `HandleLidSwitchExternalPower=ignore`,
        `HandleLidSwitchDocked=ignore`. It takes effect after a reboot; don't
        restart systemd-logind, as that ends the session.
   - **No lock before a manual suspend** (only if they also want that):
     `systemctl --user mask omarchy-sleep-lock.service`.

7. **Backups.** Offer automatic restic backups to a second disk and/or a USB disk,
   with progress in the bar. Follow "Backups going forward" in [backup.md](backup.md).

8. **Optional extras.** Ask about each; set up only what they want:
   - **Dictation** (Voxtype, push-to-talk speech to text): `omarchy-voxtype-install`
     in a visible terminal.
   - **Fingerprint** login and sudo, only if `omarchy-hw-fingerprint` succeeds:
     `omarchy setup security fingerprint` in a visible terminal.
   - **AirPods** battery and controls in the bar:
     `omarchy plugin add https://github.com/thisisgm/omarchy-pods --enable --yes`,
     then run the plugin's `setup` script (builds a small daemon; read its README).
   - **Terminal apps** for Mail (Gmail), Slack and Trello, each with a bar widget
     and keybinding. Each needs the person's own account and API credentials, so
     only offer them if they use the service:
     `omarchy plugin add https://github.com/petrzpav/omarchy-<mail|slack|trello>.git --yes`,
     then follow that plugin's README "Install" section: run its `install.sh`
     and walk the person through creating the token (the README says where).
     Add the matching bar widget with `omarchy plugin enable petrzpav.<name>` and
     a keybinding in `~/.config/hypr/bindings.lua`, e.g.
     `o.bind("SUPER + SHIFT + K", "Slack", os.getenv("HOME") .. "/.local/bin/slack-window")`
     (Mail: `SUPER + SHIFT + E` with `mail-window`, after `hl.unbind("SUPER + SHIFT + E")`;
     Trello: `SUPER + SHIFT + R` with `trello-window`).
   - **Wallpaper rotation**: wallswap is installed and swaps the background from
     Wallhaven every 180 minutes. Ask if they'd rather keep a fixed wallpaper; if
     so, `omarchy plugin disable petrzpav.wallswap`.

9. **Tour.** Show `CHEATSHEET.md` from this repo as a short list, then point to
   `omarchy menu keybindings` (or Super+K) for everything else. Mention:
   update the shared setup with `cd ~/.local/share/omarchy-setup && git pull && ./install`,
   undo with `./install --restore`.

End with a short summary of what changed and which files hold their personal
settings.
