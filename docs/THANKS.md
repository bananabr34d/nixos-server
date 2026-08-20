# Thanks

This repository is an arrangement of other people's work.

## The operating system

- **[NixOS](https://nixos.org)** and **[nixpkgs](https://github.com/NixOS/nixpkgs)** — Eelco Dolstra started Nix; thousands of people keep the module system honest.
- **[home-manager](https://github.com/nix-community/home-manager)** — even a headless box deserves a declared shell.

## The flake shape

- **[flake-parts](https://github.com/hercules-ci/flake-parts)** (Robert Hensing / hercules-ci)
- **[The dendritic pattern](https://github.com/mightyiam/dendritic)** — Shahar “Dawn” Or ([@mightyiam](https://github.com/mightyiam)). Every non-entry file is a top-level module. Lived in at [mightyiam/infra](https://github.com/mightyiam/infra).
- **[import-tree](https://github.com/vic/import-tree)** (Victor Borja, [@vic](https://github.com/vic)) — walk `modules/` and load every file. Vic’s config: [vix](https://github.com/vic/vix). Toolkit: [denful](https://denful.dev/) (formerly den.oeiuwq.com).
- **[Gaétan Lepage](https://github.com/GaetanLepage/nix-config)** ([@GaetanLepage](https://github.com/GaetanLepage)) — dendritic NixOS with a NAS (`tank`) and replica (`backup`), the closest public cousin to this pair.
- **[nix-systems](https://github.com/nix-systems/default)**

## Disks, secrets, deploy

- **[disko](https://github.com/nix-community/disko)** — disks as code. It will format what you name.
- **[sops-nix](https://github.com/Mic92/sops-nix)** (Mic92)
- **[Harmonia](https://github.com/nix-community/harmonia)** — a binary cache that is just a NixOS service.
- **[nh](https://github.com/nix-community/nh)** and **[just](https://github.com/casey/just)** (Casey Rodarmor)

## Storage and replication

- **[OpenZFS](https://openzfs.org)** — the reason a dead motherboard is not a dead photo library.
- **[sanoid / syncoid](https://github.com/jimsalterjrs/sanoid)** (Jim Salter) — snapshots and `zfs send` with a timer, not a folklore wiki.

## The apps

- **[Immich](https://immich.app)** — photos you host.
- **[Forgejo](https://forgejo.org)** — git you host.
- **[Caddy](https://caddyserver.com)** — the HTTPS front door.
- **[ntfy](https://ntfy.sh)** — "the disk is unhappy" on your phone.
- **[Tailscale](https://tailscale.com)** — the network that makes the front door private.
- **[Samba](https://www.samba.org)** + Apple's fruit VFS notes — Time Machine without a NAS appliance.

## Configs we learned from

- **[wimpysworld/nix-config](https://github.com/wimpysworld/nix-config)** — installer script tone.
- Public NixOS homelab write-ups that treated "primary + syncoid standby" as a normal shape, not a whitepaper.
- Teaching from **Vimjoyer** and the rest of the NixOS explainers.

If you see your pattern here and your name is missing, open a PR.
