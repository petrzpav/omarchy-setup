# Restore and backups

## Restore from an old backup

Goal: the person's files, keys and app settings from their previous computer, without
ever silently overwriting something on this one.

### Find the backup

Ask where it is: a USB disk, a second internal disk, a NAS share, a cloud bucket.
For disks, look before asking: `lsblk -f`, and mounted media under `/run/media/$USER/`.
An encrypted disk needs unlocking first: `udisksctl unlock -b /dev/<part>` (asks for
the passphrase; run it in a visible terminal), then `udisksctl mount -b /dev/mapper/...`.

A restic repo is a folder holding `config`, `data/`, `index/`, `keys/` and `snapshots/`:

```bash
find /run/media/$USER /mnt /data* -maxdepth 4 -name keys -type d 2>/dev/null | xargs -r -n1 dirname
```

If it's not restic (borg, duplicity, Déjà Dup, Time Machine, a plain copy), say what
you found and adapt the steps below to that tool; install it with `omarchy pkg add`.

### Open it

```bash
omarchy pkg add restic        # in a visible terminal if sudo asks for a password
export RESTIC_REPOSITORY=/run/media/$USER/<label>/<repo>
restic --insecure-no-password snapshots   # works if the repo has no password
```

If that fails with a password error, ask for the password and put it in a temporary
file (`umask 077; ... > "$XDG_RUNTIME_DIR/restic-pw"`, `export RESTIC_PASSWORD_FILE=...`).
Never echo the password back, and delete the file at the end.

Pick the newest snapshot from the old computer (`restic snapshots` shows host and
paths). Its home folder is in the paths, e.g. `/home/olduser`; the user name may
differ from today's, which is fine.

### Choose what to restore

List the old home's top level (`restic ls <id> /home/olduser`, which is not recursive)
and present it in groups. Estimate sizes for big folders with
`restic ls --long --recursive <id> <path> | awk '{s+=$4} END {print s/1e9 " GB"}'`
and check free space with `df -h ~`.

1. **Files**: Work, projects, Documents, Pictures, Music, Videos, Desktop, Downloads.
2. **Keys and logins**: `.ssh`, `.gnupg`, `.password-store`, `.config/gh`, `.gitconfig`,
   `.config/git`, `.git-credentials`, `.netrc`, `.aws`, `.kube`, `.docker/config.json`.
3. **Shell and tools**: `.bashrc`, `.zshrc`, `.inputrc`, `.local/bin`, `.config/nvim`,
   `.config/starship.toml`, `.config/lazygit`, other `.config/<tool>` folders.
4. **Apps**: browser profiles (`.config/chromium`, `.config/google-chrome`,
   `.config/BraveSoftware`, `.mozilla`), `.config/Code`, chat apps, plugin data
   (`.config/petrzpav-*`, `.local/share/petrzpav-*`), backup settings (`.config/restic`).
5. **Desktop** (only when the old computer ran Omarchy): `.config/hypr`,
   `.config/omarchy` (plugins, bar, themes), `.config/systemd/user`. Restoring this
   replaces what `./install` set up, which is what someone moving their own setup
   wants. Keep today's `monitors.lua` and `input.lua` unless the hardware is the same.
6. **Data volumes**: other paths in the snapshot (e.g. `/data`, `/data2`). Ask where
   they should go on this machine.

Offer "everything from my old home" too. Then restore in the background
(`run_in_background`) for anything big, and say how much is left now and then.

### Restore without clobbering

- A path that doesn't exist here yet: restore it straight into place
  `restic restore "<id>:/home/olduser/Work" --target ~/Work`.
- A path that exists here (a fresh install already made it): restore to
  `~/restored-<date>/<path>` first, show the differences, and ask which to keep.
  For "everything, old wins", `restic restore "<id>:/home/olduser" --target ~ --overwrite always`
  is fine once the person said so; still keep today's `monitors.lua`/`input.lua`
  unless they asked for those too.
- After restoring: `chmod 700 ~/.ssh ~/.gnupg; chmod 600 ~/.ssh/id_*` (not `.pub`).

### Bring restored apps back to life

- Plugins in `~/.config/omarchy/plugins/`: run each one's `install.sh` if it has
  one (it relinks commands, services and Claude skills), then `omarchy-shell shell rescanPlugins`.
- User services: `systemctl --user daemon-reload`, then re-enable what was enabled
  on the old machine. The restored `~/.config/systemd/user/*.wants/` and
  `timers.target.wants/` links show which; enable those units again so systemd
  re-creates the links (`systemctl --user enable --now <unit>`), asking first.
- `hyprctl reload` and `hyprctl configerrors` after restoring `.config/hypr`.
- If `~/.config/restic/backup.conf` came back, the backup step below only needs
  re-enabling.

## Backups going forward

`extras/backup/` holds a small restic setup: `backup-usb` backs up `$HOME` (and data
volumes) to a repo on a second disk every few hours and to a USB disk whenever it's
plugged in, shows progress in the bar, and keeps 7 daily, 8 weekly and 24 monthly
snapshots. Settings live in `~/.config/restic/backup.conf`.

1. If `~/.config/restic/backup.conf` exists (restored), show it, check its repos
   and disks still exist on this machine, fix paths together, and go to step 5.
2. Ask where backups should go: a second internal disk, a USB disk (which one;
   its filesystem label from `lsblk -f`), or both. A backup on the same disk as
   the home folder only protects against mistakes, not disk failure; say so.
3. Password: recommend one. Generate it (`openssl rand -base64 24`), write it to
   `~/.config/restic/password` (`chmod 600`), and ask the person to store a copy in
   their password manager now: without it nothing can be restored. If they don't
   want one, leave `PASSWORD_FILE` empty.
4. Install:
   - `omarchy pkg add restic`
   - copy `extras/backup/backup-usb` to `~/.local/bin/`, `backup-progress` to
     `~/.config/omarchy/bar/scripts/`, `excludes.example` to `~/.config/restic/excludes`
     (keep an existing one);
   - write `~/.config/restic/backup.conf` from `backup.conf.example` with their answers;
   - create each repo: `restic init -r <repo>` (with `--password-file` or
     `--insecure-no-password`);
   - copy `backup-usb.timer` and `backup-usb.service` to `~/.config/systemd/user/`;
     in the service, replace `@MOUNT_UNIT@` with
     `systemd-escape -p --suffix=mount /run/media/$USER/<label>`, or delete the
     `[Install]` section when there is no USB disk.
5. Enable (ask first): `systemctl --user daemon-reload`,
   `systemctl --user enable --now backup-usb.timer`, and with a USB disk
   `systemctl --user enable backup-usb.service`.
6. Add the bar widget: insert `extras/backup/bar-widget.json` as the first item of
   `.bar.layout.right` in `~/.config/omarchy/shell.json` (jq; back up the file first).
7. Run the first backup in the background, `~/.local/bin/backup-usb --force`, and
   show the result with `restic snapshots`. `backup-usb --print` shows what would run.
