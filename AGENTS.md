# nixos-server

Public template. Not a live homelab.

- Identity / tailnet: `lib/me.nix`
- Never turn apps on on `standby` except as a documented promote
- Never rewrite a live ZFS `hostId`
- Do not commit secrets
- Disko wipes every device listed in a host's `disko.nix`
- Docs: README.md → docs/HOW-IT-WORKS.md
