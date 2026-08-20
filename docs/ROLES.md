# Roles

`homelab.role` is a single switch. The same module tree behaves as two different machines.

| | primary | standby |
|--|---------|---------|
| Immich, Forgejo, Caddy | on | off |
| Harmonia | optional | off |
| ntfy | on | off (it *sends* to primary) |
| Samba + Avahi | on | forced off |
| Sanoid | snapshot + prune | prune only |
| Syncoid | off (it *receives* SSH) | on (pull) |
| SMART | on → ntfy | on → ntfy on primary |

## Why apps stay off on standby

ZFS send/recv is not a cluster. If both machines accepted photo uploads you would have two histories and no good merge. The spare is a **copy**, not a second live site.

## Promote (when the primary is gone)

This is a drill you should run once on purpose.

1. Confirm the primary is actually dead (or take it off the tailnet).
2. On standby, in `configuration.nix`: `homelab.role = "primary";` and set `networking.hostName` / Tailscale hostname to whatever clients already use — *or* point DNS/MagicDNS at the spare and keep the name `standby` if you can tolerate new URLs.
3. `just switch` on the spare.
4. Samba: `smbpasswd -a` again (passdb is not in the replicated datasets unless you added it).
5. Forgejo/Immich: they will see the replicated data under `/data`. Postgres *settings* on the private flake live on the OS disk — this template keeps app state under `/data` where possible; still check both after promote.

There is no automatic failover in this repo. That is a decision, not a missing feature. See [DECISIONS.md](DECISIONS.md).

## Demote / rebuild a primary

Install a new primary with a **new** `hostId` if the disks are new. If you reuse the old tank disks, keep the old `hostId` and import the pool; do not disko-create tank.
