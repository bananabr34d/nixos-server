# Decisions

An extract, not a dump. The private lab this came from runs more
services and knows more family names than a public template should.

## import-tree `/_` skip, and treefmt as a flake check

import-tree ignores any path containing `/_`. That is how Gaétan
Lepage keeps `_utils` / `_keys` out of the chapter registry.

Formatting is [treefmt-nix](https://github.com/numtide/treefmt-nix)
(nixfmt, deadnix, statix): `nix fmt` / `just format`, and
`nix flake check` fails if the tree is dirty (same idea as Gaétan
and mightyiam).

## Hosts import `home-manager`, not `dev`

The private flake (and an earlier draft of this template) used a
wrapper chapter `flake.modules.nixos.dev` that only imported
`home-manager`. The name was leftover and wrong on a NAS. Hosts
import `home-manager` directly. That chapter stays out of `core` so
a future appliance host can skip a declared user home.

## One role flag, not two flakes

Primary and standby share `server-base` + `homelab-apps`. The
difference is `homelab.role`. Two separate server flakes would
drift. One flake with a boolean you can flip for a promote drill
is the whole design.

## Standby does not run the apps

Warm standby, not active-active. Syncoid pull (standby reaches
out) so the primary does not need to know the spare's current IP.
Sanoid on the spare only prunes: autosnapshots on both ends
collide and break receive.

## ZFS tank + ext4 (or ZFS local) OS

Data that must survive a motherboard swap lives on **tank**. The
OS can be ext4 on NVMe (simple, what the example primary does) or
ZFS `local` (what the example standby does). Mixing those on
purpose shows both layouts.

`hostId` is sacred. Changing it on a machine that still owns a
pool is how you get a very long night.

## Tailscale is the front door

Caddy's certificates come from `tailscaled`, not from Let's
Encrypt on a public A record. The LAN firewall still matters;
the tailnet is trusted (`trustedInterfaces = [ "tailscale0" ]`).
Do not port-forward Immich or Forgejo to the WAN.

## Harmonia is opt-in

A binary cache needs a signing secret. Shipping a fake one is
worse than shipping none. `homelab.cache.enable` stays false
until sops is real. `just push-cache` then builds on a fast
machine and `nix copy`s into the primary.

The private lab always trusts that cache from every host. The
template does not, so a clone without Harmonia still evaluates
and still substitutes from `cache.nixos.org`.

## What we left out

| Left out | Why |
|----------|-----|
| Family Samba accounts | Personal; the pattern is "one share per Unix user" — add yours |
| AdGuard as LAN DHCP | Easy to brick a house network from a template |
| Glance dashboards | Personal links and YouTube ids |
| Borg-to-USB with a hard-coded serial | House hardware; keep 3-2-1 offsite however you already do |
| Uptime Kuma | Nice; not required to understand the pair |
| nixos-stable split | The private flake wants this later; 25.11 + current home-manager did not eval. Document, don't ship a broken pin. |

## Things you might steal back from a more complete lab

- OS-state backups (Kuma/Samba/sops/Postgres) onto tank
- Uptime Kuma + push heartbeats
- AdGuard Home *after* you have a written DHCP cutover plan
- A desktop flake that `just push-cache`s into this Harmonia

## sops stays optional on first boot

Same as the desktop template: a missing `secrets/secrets.yaml`
must not make `nix flake check` fail. Wire it when Harmonia
turns on.
