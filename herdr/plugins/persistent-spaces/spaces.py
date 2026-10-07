#!/usr/bin/env python3
# Persistent herdr spaces: a space that closes because its last tab or pane
# went away is recreated with the same name, directory and position. Only the
# "delete" action removes a space for good.
#
#   spaces.py remember  - record every live space (startup + workspace events)
#   spaces.py closed    - workspace/tab/pane close hook: recreate the space
#                         if it is gone and was not deleted
#   spaces.py delete    - action: close the current space for good
import fcntl
import hashlib
import json
import os
import socket
import subprocess
import sys

HERDR = os.environ.get("HERDR_BIN_PATH") or "herdr"
SOCK = os.environ.get("HERDR_SOCKET_PATH") or os.path.expanduser("~/.config/herdr/herdr.sock")
STATE_DIR = os.environ.get("HERDR_PLUGIN_STATE_DIR") or os.path.expanduser("~/.local/state/herdr-persistent-spaces")
# One registry per herdr session (named sessions have their own socket)
KEY = hashlib.sha1(SOCK.encode()).hexdigest()[:12]
REGISTRY = os.path.join(STATE_DIR, f"spaces-{KEY}.json")
DELETED = os.path.join(STATE_DIR, f"deleted-{KEY}")


def herdr(*args):
    out = subprocess.run([HERDR, *args], capture_output=True, text=True)
    if out.returncode != 0:
        raise SystemExit(f"herdr {' '.join(args)}: {out.stderr.strip()}")
    return json.loads(out.stdout)["result"] if out.stdout.strip() else None


def call(method, params):
    """Raw socket request, for what the CLI lacks (workspace.move)."""
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.connect(SOCK)
        s.sendall((json.dumps({"id": "persistent-spaces", "method": method, "params": params}) + "\n").encode())
        buf = b""
        while not buf.endswith(b"\n"):
            chunk = s.recv(65536)
            if not chunk:
                break
            buf += chunk
    resp = json.loads(buf)
    if "error" in resp:
        raise SystemExit(f"{method}: {resp['error']}")
    return resp["result"]


def load(path, default):
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, ValueError):
        return default


def save(path, data):
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(data, f, indent=1)
    os.replace(tmp, path)


def space_dirs():
    """workspace_id -> directory: herdr's own identity cwd, else the first pane's cwd."""
    dirs = {}
    for pane in herdr("api", "snapshot")["snapshot"].get("panes", []):
        dirs.setdefault(pane["workspace_id"], pane.get("cwd"))
    session = load(os.path.join(os.path.dirname(SOCK), "session.json"), {})
    for ws in session.get("workspaces", []):
        if ws.get("identity_cwd"):
            dirs[ws["id"]] = ws["identity_cwd"]
    return dirs


def remember():
    spaces = herdr("workspace", "list")["workspaces"]
    dirs = space_dirs()
    registry = load(REGISTRY, {})
    live = {}
    for index, ws in enumerate(spaces):
        wid = ws["workspace_id"]
        live[wid] = {
            "label": ws["label"],
            "cwd": dirs.get(wid) or registry.get(wid, {}).get("cwd"),
            "index": index,
            "focused": ws["focused"],
        }
    # Keep entries of spaces that just closed until the closed hook handles them
    for wid, entry in registry.items():
        live.setdefault(wid, entry)
    save(REGISTRY, live)


def closed():
    event = json.loads(os.environ.get("HERDR_PLUGIN_EVENT_JSON") or "{}")
    data = event.get("data", event)
    wid = data.get("workspace_id") or (data.get("workspace") or {}).get("workspace_id")
    if not wid:
        return
    if any(ws["workspace_id"] == wid for ws in herdr("workspace", "list")["workspaces"]):
        return  # a pane or tab closed, but the space is still there
    registry = load(REGISTRY, {})
    entry = registry.pop(wid, None)
    deleted = set(load(DELETED, []))
    if wid in deleted:
        deleted.discard(wid)
        save(DELETED, sorted(deleted))
        save(REGISTRY, registry)
        return
    save(REGISTRY, registry)
    if not entry:
        return
    args = ["workspace", "create", "--label", entry["label"]]
    if entry.get("cwd") and os.path.isdir(entry["cwd"]):
        args += ["--cwd", entry["cwd"]]
    args.append("--focus" if entry.get("focused") else "--no-focus")
    new_id = herdr(*args)["workspace"]["workspace_id"]
    call("workspace.move", {"workspace_id": new_id, "insert_index": entry["index"]})
    remember()


def delete():
    context = json.loads(os.environ.get("HERDR_PLUGIN_CONTEXT_JSON") or "{}")
    wid = (
        os.environ.get("HERDR_WORKSPACE_ID")
        or context.get("workspace_id")
        or (context.get("workspace") or {}).get("workspace_id")
    )
    if not wid:
        raise SystemExit("delete: no current space")
    deleted = set(load(DELETED, []))
    deleted.add(wid)
    save(DELETED, sorted(deleted))
    herdr("workspace", "close", wid)


if __name__ == "__main__":
    os.makedirs(STATE_DIR, exist_ok=True)
    with open(os.path.join(STATE_DIR, f"lock-{KEY}"), "w") as lock:
        if sys.argv[1] != "delete":
            fcntl.flock(lock, fcntl.LOCK_EX)
        {"remember": remember, "closed": closed, "delete": delete}[sys.argv[1]]()
