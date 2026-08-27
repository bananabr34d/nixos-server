# nixos-server

A recipe for a small house server — and a second machine that quietly holds a copy.

In plain language: one computer runs the things you actually use (photos, a git website, a shared folder, a Nix binary cache). A second computer stays mostly idle and pulls a nightly copy of the important disks. If the first machine dies, you still have the data. You promote the second machine when you are ready; until then it does not run the apps, so you cannot accidentally write to both copies.

The pair talks over **Tailscale** (a private network between your machines). HTTPS names come from Tailscale certificates. Disks that hold photos and git are **ZFS** mirrors: two drives, one pool, so one drive can fail without taking the library with it.

This is a **template**. It is derived from a private homelab flake. It is not a drop-in for someone else's rack, and it does not include every service that house runs.

**Host it lives under:** [github.com/bananabr34d/nixos-server](https://github.com/bananabr34d/nixos-server)

Sister recipe: [nixos-desktop](https://github.com/bananabr34d/nixos-desktop) — a Niri + Noctalia laptop/desktop. Separate on purpose.

## What you get

```text
                 Tailscale + Caddy (HTTPS)
                            │
           ┌────────────────┴────────────────┐
           ▼                                 ▼
     primary (live)                    standby (warm)
     Immich / Forgejo ON               apps OFF
     Caddy + Harmonia ON               syncoid pull
     ntfy + SMART                      SMART → ntfy on primary
     sanoid (snapshots)                sanoid (prune only)
           │                                 ▲
           └──── ZFS send/recv (SSH) ────────┘
                 tank/immich + tank/forgejo + tank/documents
```

| Role | Runs |
|------|------|
| **primary** | Immich (photos), Forgejo (git), Caddy, optional Harmonia cache, Samba + Time Machine, ntfy |
| **standby** | ZFS receive, SMART, snapshots pruned. No public apps. |

## Start here (in order)

1. [docs/HOW-IT-WORKS.md](docs/HOW-IT-WORKS.md) — the picture above, in words.
2. Edit [lib/me.nix](lib/me.nix) — you, the Tailscale domain, the primary hostname.
3. Put real `/dev/disk/by-id/...` paths and unique `hostId`s in each host's `disko.nix`.
4. [docs/INSTALL.md](docs/INSTALL.md) — wipe, install, first `tailscale up`, syncoid key.
5. [docs/ROLES.md](docs/ROLES.md) — what "promote" means when you need it.

## Daily commands

```bash
cd ~/nixos-server
just pull-switch                 # this machine
# from a fast Linux box, after Harmonia is on:
just push-cache primary standby
just smoke primary
```

`just switch` is local only. Sit at the machine you are changing.

## Map of the repo

```text
lib/me.nix                 ← you + tailnet name
lib/homelab-modules/       ← role logic (primary / standby / always)
flake.nix                  ← ingredient list
modules/flake/             ← host factory
modules/nixos/core/        ← ssh, dns, nix, users
modules/nixos/core/services/ server-base + homelab-apps
modules/hosts/primary/     ← live server disk + role
modules/hosts/standby/     ← replica disk + role
docs/
```

## Do not

- Rewrite a live ZFS `networking.hostId`
- Turn Immich/Forgejo/Samba **on** the standby (that is the whole point)
- Commit decrypted secrets or an age private key
- Point disko at an existing tank you still need — it will create a *new* pool
- Apply this flake to a machine you are not sitting on

## Thanks

Full list: [docs/THANKS.md](docs/THANKS.md). Short version: NixOS/nixpkgs, flake-parts, import-tree, home-manager, disko, sops-nix, ZFS on Linux, Harmonia, Tailscale, sanoid/syncoid, Immich, Forgejo, Caddy, ntfy — and the public configs (including wimpysworld's installer shape) that made a primary/standby pair feel obvious instead of heroic.

## More

| Doc | When |
|-----|------|
| [docs/HOW-IT-WORKS.md](docs/HOW-IT-WORKS.md) | Mental model |
| [docs/MODULES.md](docs/MODULES.md) | Every `flake.modules.*` name |
| [docs/INSTALL.md](docs/INSTALL.md) | First metal |
| [docs/ROLES.md](docs/ROLES.md) | Primary vs standby, promote |
| [docs/DECISIONS.md](docs/DECISIONS.md) | Why this shape |
| [docs/THANKS.md](docs/THANKS.md) | Credits |
