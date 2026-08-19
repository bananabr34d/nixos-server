# How this flake works

## In ordinary language

Two computers, one job.

The **primary** is the house server. It holds the photo library, the
git websites, the shared folder, and (optionally) a cache of already
built software so the next install is a download, not a compile.

The **standby** is a spare with the same *kind* of disks. Every night
it asks the primary for a copy of the important ZFS datasets. It does
not run Immich or Forgejo. That way a mistake on the spare cannot
change the live library.

If the primary dies, the data is already on the standby. Promoting is
a deliberate step (see [ROLES.md](ROLES.md)), not an automatic
failover. Automatic failover sounds brave and is how you get two
primaries.

They find each other on **Tailscale**, a private network. Caddy on
the primary asks Tailscale for a certificate, so
`https://primary.your-tailnet.ts.net/` is photos and
`/git/` is Forgejo. You do not open those ports on the public
internet.

### The recipe book

Same idea as the desktop flake: `lib/me.nix` is you, `flake.nix` is
the shopping list, `modules/` is the recipe, `modules/hosts/<name>/`
is one machine's disk and hostname. `import-tree` loads every file
under `modules/`. `nixos-hosts.nix` is the factory that turns
"primary exists" into `nixosConfigurations.primary`.

The only extra idea is **`homelab.role`**. One module
(`homelab-apps`) reads that flag and either starts the apps or
starts syncoid. You do not maintain two unrelated server configs.

## In Nix language

```text
flake.nix
  → flake-parts + import-tree ./modules
      → nixosConfigurations.primary / .standby
      → each host imports
            core + bootloader + dev + server-base + homelab-apps
      → homelab-apps imports lib/homelab-modules/{options,always,primary,standby}
      → primary.nix is mkIf (role == "primary")
      → standby.nix is mkIf (role == "standby")
```

`lib/homelab-modules/` sits *outside* `modules/` on purpose: those
files are ordinary NixOS modules, not flake-parts fragments. That
keeps `mkIf isPrimary` readable.

## What to edit

| Change this | Leave this unless you know why |
|-------------|-------------------------------|
| `lib/me.nix` | `modules/flake/` |
| each `disko.nix` disk by-id + `hostId` | Dataset *names* (`tank/immich`, …) — syncoid maps them 1:1 |
| `homelab.syncoidPubKey` on primary | Turning apps on on the standby |
| `homelab.cache.enable` after sops | `forceImport*` if you ever import tank on two hosts at once |
