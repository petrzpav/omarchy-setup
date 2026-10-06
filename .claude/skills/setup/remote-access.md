# Remote access from the iPhone (Tailscale + Heeler)

[Heeler](https://apps.apple.com/us/app/heeler-for-herdr/id6797263135) is an iOS app
for [herdr](https://herdr.dev). It lists the coding agents running in herdr, attaches
to their live terminals and sends push notifications when one is Blocked or Done. It
connects over plain SSH, and Tailscale SSH serves that SSH, so the machine needs no
sshd and no open ports.

Check the current state first: `tailscale status`, `tailscale debug prefs | grep RunSSH`,
`herdr --version`, `herdr plugin list`, `node --version`. Skip whatever is already done.

1. **Tailscale on this machine.** `omarchy-install-service-tailscale` in a visible
   terminal (it installs the package and enables `tailscaled`). Then run
   `sudo tailscale up --ssh --operator=$USER` there too and have the person log in
   in the browser. `--ssh` turns on Tailscale SSH. `--operator` lets them run
   `tailscale` without sudo later. On a machine that is already up, use
   `sudo tailscale set --ssh`.

2. **Tailscale on the iPhone.** The person installs the Tailscale app from the App
   Store and logs in with the same account. Wait until the phone shows up in
   `tailscale status`.

3. **SSH policy: accept, not check.** The default tailnet policy uses `"action": "check"`
   for SSH. That asks for a browser login again every few hours, and Heeler can't
   show that prompt, so its connections just time out (`journalctl -u tailscaled`
   then shows `failed to fetch next SSH action ... context deadline exceeded`).
   Ask the person to open https://login.tailscale.com/admin/acls and set the `ssh`
   section to:

   ```json
   "ssh": [
     {"action": "check",  "src": ["autogroup:member"], "dst": ["autogroup:self"], "users": ["root"]},
     {"action": "accept", "src": ["autogroup:member"], "dst": ["autogroup:self"], "users": ["autogroup:nonroot"]}
   ]
   ```

   Explain the trade-off. `autogroup:self` means only their own devices can connect,
   and Tailscale still authenticates every device by its key. `accept` only drops
   the extra periodic browser login. Root keeps `check`.
   Verify that the change arrived: in
   `tailscale debug netmap | jq .SSHPolicy`, the non-root rule should have `"accept": true`.

4. **herdr and the Heeler plugin.** herdr needs to be running, and the plugin needs
   Node ≥ 20. If `herdr` is missing, run `omarchy pkg add herdr`. Then:

   ```bash
   herdr plugin install ZingerLittleBee/Heeler/plugin --ref main --yes
   herdr plugin action invoke heeler.pair
   ```

   Run the pair action inside herdr, or in a visible terminal, because it shows a QR code.

5. **Pair the phone.** The person installs Heeler from the App Store, taps add host,
   scans the QR code and picks the Tailscale address (100.x or the machine name) as
   the host. Then they turn on notifications for the host in the app.

6. **Test it.** Have them open an agent in Heeler. In `journalctl -u tailscaled --since -5min | grep ssh`
   you should see `access granted ... as ssh-user "<user>"`.

Tell the person that the machine has to be awake to be reached. If they want it
reachable with the lid closed, point them back to step 6 of the setup (lid and locking).
