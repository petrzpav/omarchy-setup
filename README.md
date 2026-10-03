# omarchy-setup

My [Omarchy](https://omarchy.org) setup, ready to apply on top of a fresh install:
Monokai Pro theme, tighter gaps and rounded corners, a bottom transparent bar with a
workspace pager and status indicators, rotating wallpapers and crash-safe screen
recording. After that, an AI agent sets up the parts that depend on you: monitors,
keyboard, accounts and optional apps.

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

## Finish by hand

Without an agent, go through the steps in [`.claude/skills/setup/SKILL.md`](.claude/skills/setup/SKILL.md):
monitors (`~/.config/hypr/monitors.lua`), keyboard (`~/.config/hypr/input.lua`),
git identity, lid and idle locking, and the optional extras (dictation, fingerprint, AirPods, the Mail/Slack/Trello
terminal apps).

Keybindings: [CHEATSHEET.md](CHEATSHEET.md).

## Maintainer: keeping the repo in step

On the maintainer's machine `tools/sync --watch` (a systemd user service, set up
with `tools/sync --install-service`) watches the live config. A few seconds after a
change it copies the shared parts into the repo, commits and pushes:

- theme `~/.config/omarchy/themes/monokai-pro`, the indicators plugin and the screen
  recording scripts, copied as they are;
- the bar layout from `~/.config/omarchy/shell.json`, without personal widgets
  (listed in `PERSONAL_WIDGETS` in `tools/sync`);
- `hypr/team.lua`, which the maintainer's Hyprland loads straight from the repo;
- `packages.txt`: packages installed on top of Omarchy, minus Omarchy's own and the
  personal ones in `PERSONAL_PACKAGES`, refreshed after every pacman run.

A commit that looks like it contains a credential is refused, with a notification.
Logs: `journalctl --user -u omarchy-setup-sync -f`.
