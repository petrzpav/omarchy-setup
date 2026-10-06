# omarchy-setup

A shared Omarchy setup: `bootstrap` (curl entry point) clones this repo to
`~/.local/share/omarchy-setup` and runs `install`, then starts the `/setup` skill
(`.claude/skills/setup/SKILL.md`) for per-person configuration.

- `install` is modular, idempotent and supports `--dry-run` and `--restore`. Keep new
  modules the same way: copy with `sync`, call `backup` before changing a file, and
  report each change with `step` / `skip`.
- `hypr/team.lua` is loaded from `~/.config/hypr/hyprland.lua` via `dofile` (absolute
  path to this repo), after Omarchy's defaults and before the person's own files.
  Only machine-independent settings belong here; monitors and input are per person.
- Nothing personal goes in this repo: no tokens, account-bound plugins, or
  hardware-specific config.
- When a person asks to change their setup, edit their `~/.config/`, not this repo.

## Branches, versions and changelog

Changes to this repository itself (not to a person's setup) are managed by [Flow](https://github.com/internetguru/flow). Follow the
`ig-flow` and `ig-changelog` skills from
[internetguru/laravel-scripts](https://github.com/internetguru/laravel-scripts/tree/main/resources/boost/skills)
for branches, commits, releases, `VERSION` and `CHANGELOG.md`. If you don't have them,
download them first and read them:

```bash
for s in ig-flow ig-changelog; do
  mkdir -p ~/.claude/skills/$s
  curl -fsSL "https://raw.githubusercontent.com/internetguru/laravel-scripts/main/resources/boost/skills/$s/SKILL.md" \
    -o ~/.claude/skills/$s/SKILL.md
done
```
