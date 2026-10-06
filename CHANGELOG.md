# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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

[0.1.3]: https://github.com/petrzpav/omarchy-setup/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/petrzpav/omarchy-setup/compare/v0.1.1...v0.1.2
[0.1.1]: https://https://github.com/petrzpav/omarchy-setup/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/petrzpav/omarchy-setup/releases/tag/v0.1.0
