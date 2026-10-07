# omarchy-setup

My [Omarchy](https://omarchy.org) setup, ready to apply on top of a fresh install:
Monokai Pro theme, tighter gaps and rounded corners, a bottom transparent bar with a
workspace pager and status indicators, rotating wallpapers and crash-safe screen
recording. After that, an AI agent sets up the parts that depend on you: it brings
back your files and settings from an old backup, then monitors, keyboard, automatic
backups, accounts and optional apps.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/petrzpav/omarchy-setup/main/bootstrap | bash
```

This clones the repo to `~/.local/share/omarchy-setup`, runs `./install`, and then
starts Claude Code with `/setup` (or your Omarchy default agent) to finish
the setup with you. You can stop the agent at any time and start it again later:

```bash
cd ~/.local/share/omarchy-setup && claude /setup
```

To see what would change before you run it:

```bash
git clone https://github.com/petrzpav/omarchy-setup.git ~/.local/share/omarchy-setup
~/.local/share/omarchy-setup/install --dry-run
```

## What `./install` does

| Module | Changes |
|---|---|
| `packages` | Installs the apps and tools in [`packages.txt`](packages.txt) that are missing (asks for your sudo password) |
| `theme` | Copies the Monokai Pro theme to `~/.config/omarchy/themes/` and makes it the active theme |
| `hypr` | Adds a line to `~/.config/hypr/hyprland.lua` that loads [`hypr/team.lua`](hypr/team.lua) (gaps, rounding, keybindings); copies the screen recording scripts to `~/.local/bin` |
| `plugins` | Installs the bar plugins [omapager](https://github.com/njpatel/omapager), [wallswap](https://github.com/petrzpav/omarchy-wallswap) and the bundled `petrzpav.indicators` |
| `bar` | Replaces the `bar` section of `~/.config/omarchy/shell.json` with [`shell/bar.json`](shell/bar.json); your other shell settings stay |
| `herdr` | Replaces `~/.config/herdr/config.toml` with [`herdr/config.toml`](herdr/config.toml) (tmux-like keys on Ctrl + Space); copies the space switcher, sort and theme scripts to `~/.local/bin`; links the [persistent spaces](herdr/plugins/persistent-spaces) plugin |

Run only some modules with `./install theme bar`; list them with `./install --list`.
Every run backs up each file it touches to `~/.local/state/omarchy-setup/backups/`.
`--restore` brings files back but does not uninstall packages.

## Your own changes

`hypr/team.lua` loads **before** your `~/.config/hypr/{monitors,input,bindings,looknfeel,autostart}.lua`,
so anything you set there wins. Put your changes there, not in this repo, and updates
won't overwrite them.

## Update and undo

```bash
cd ~/.local/share/omarchy-setup && git pull && ./install   # update
./install --restore                                         # undo the last run
./install --restore 20261003-171500                         # undo a specific run
```

## What the agent can't do for you

The agent sets these up on the computer, but a few steps happen on your phone or in a web console. Do them yourself when it asks:

**Remote access from the iPhone** (Tailscale + [Heeler](https://apps.apple.com/us/app/heeler-for-herdr/id6797263135), to watch and answer your coding agents in herdr from the phone; [details](.claude/skills/setup/remote-access.md)):

1. On the iPhone, install **Tailscale** and **Heeler** from the App Store. Log in to Tailscale with the same account as the computer.
2. In the [Tailscale admin console → Access controls](https://login.tailscale.com/admin/acls), set the `ssh` section so that normal users are let in without a browser login. The default `check` keeps asking you to log in again, and Heeler times out on it:

   ```json
   "ssh": [
     {"action": "check",  "src": ["autogroup:member"], "dst": ["autogroup:self"], "users": ["root"]},
     {"action": "accept", "src": ["autogroup:member"], "dst": ["autogroup:self"], "users": ["autogroup:nonroot"]}
   ]
   ```

   Only your own devices can connect, and Tailscale still checks each device's key.
3. In Heeler, scan the QR code the agent shows on the computer and pick the Tailscale address as the host.

## Finish by hand

Without an agent, go through the steps in [`.claude/skills/setup/SKILL.md`](.claude/skills/setup/SKILL.md):
monitors (`~/.config/hypr/monitors.lua`), keyboard (`~/.config/hypr/input.lua`),
restoring from a backup and setting up backups ([backup.md](.claude/skills/setup/backup.md)),
git identity, lid and idle locking, and the optional extras (dictation, fingerprint, AirPods, the Mail/Slack/Trello
terminal apps, remote access from the iPhone via Tailscale + Heeler: [remote-access.md](.claude/skills/setup/remote-access.md)).

Keybindings: [CHEATSHEET.md](CHEATSHEET.md).

## Maintainer: keeping the repo in step

On the maintainer's machine `tools/sync --watch` (a systemd user service, set up
with `tools/sync --install-service`) watches the live config. Once nothing has changed
for five minutes it copies the shared parts into the repo and releases them the
[Flow](https://github.com/internetguru/flow) way: a hotfix branch from `main`, released
as a patch version with changelog entries (written by `claude -p`), merged back into
`dev` and pushed. The checkout then returns to the branch it was on. What it shares:

- theme `~/.config/omarchy/themes/monokai-pro`, the indicators plugin and the screen
  recording and window-hiding scripts, copied as they are;
- the bar layout from `~/.config/omarchy/shell.json`, without personal widgets
  (listed in `PERSONAL_WIDGETS` in `tools/sync`);
- `hypr/team.lua`, which the maintainer's Hyprland loads straight from the repo;
- the backup script, timer and bar script in `extras/backup/` (its settings,
  `~/.config/restic/backup.conf`, stay private);
- the herdr setup in `herdr/`: `~/.config/herdr/config.toml` without the personal
  Laravel dev binding, the `herdr-*` scripts and the persistent spaces plugin;
- `packages.txt`: packages installed on top of Omarchy, minus Omarchy's own and the
  personal ones in `PERSONAL_PACKAGES`, refreshed after every pacman run.

A change that looks like it contains a credential is refused, with a notification. So is
a sync while the repo has other uncommitted work, and any failed Flow step; the synced
changes then wait in a git stash, named in the notification.
Logs: `journalctl --user -u omarchy-setup-sync -f`.
