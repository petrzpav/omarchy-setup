# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [0.1.8] - 2026-10-07

### Changed

- `Ctrl+P` switcher in herdr lists running agents first, then spaces, so you can jump straight to an agent.

## [0.1.7] - 2026-10-07

### Added

- Herdr spaces are permanent: closing the last tab or pane, or Ctrl + D, gives the space a fresh shell, and only Prefix, Shift + K deletes it.
- The herdr module brings the herdr setup: tmux-like keys on Ctrl + Space, Ctrl + P to find a space, and sorting and theme switching.

## [0.1.6] - 2026-10-06

### Changed

- Web app keys such as Super + Shift + X bring back the web app hidden with Super + W instead of opening it again.

## [0.1.5] - 2026-10-06

### Fixed

- A hidden window brought back by its launcher returns to its own spot instead of landing next to the focused window.

## [0.1.4] - 2026-10-06

### Changed

- Super + Shift + B and Super + Shift + Return bring back the browser window hidden with Super + W, and open a new one only when none is hidden.

## [0.1.3] - 2026-10-06

### Changed

- Monokai Pro focused-window border is lighter, a pale grey instead of mid grey.

## [0.1.2] - 2026-10-06

### Added

- Super + Q closes the focused window.
- Super + W hides a window instead of closing it; the app keeps running and comes back where it was when it gets focus again, with Super + Z (the last hidden one) or Super + Alt + W (pick one).

### Changed

- The maintainer's sync releases each change as a hotfix with changelog entries, once nothing changed for five minutes.
- Super + Shift + H focuses the open Herdr window instead of opening another one.

## [0.1.1] - 2026-10-06

### Added

- Instructions for AI agents: changes to the repository follow Flow (ig-flow and ig-changelog skills).

## [0.1.0] - 2026-10-06

### Added

- Installer for the shared Omarchy setup, a `curl | bash` bootstrap, an agent setup skill and sync from the live config (`packages.txt`, extras).
- The setup skill asks about lid behaviour and idle locking; lid-switch ships as an extra.
- Restore from an old computer's backup, and automatic local / USB restic backups.
- Optional remote access from the iPhone (Tailscale + Heeler).

[Unreleased]: https://github.com/petrzpav/omarchy-setup/compare/staging...dev
[0.1.1]: https://github.com/petrzpav/omarchy-setup/compare/v0.1.0...v0.1.1
[0.1.8]: https://github.com/petrzpav/omarchy-setup/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.com/petrzpav/omarchy-setup/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/petrzpav/omarchy-setup/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/petrzpav/omarchy-setup/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/petrzpav/omarchy-setup/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/petrzpav/omarchy-setup/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/petrzpav/omarchy-setup/compare/v0.1.1...v0.1.2
[0.1.1]: https://https://github.com/petrzpav/omarchy-setup/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/petrzpav/omarchy-setup/releases/tag/v0.1.0
