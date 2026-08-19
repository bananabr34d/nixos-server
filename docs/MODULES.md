# Module registry

The book is these names, not the folders. Folders only *write into*
the registry. Several files can merge into the same name.

How a machine is assembled:

```text
nixosConfigurations.${hostname}
  = flake.modules.nixos.core
  + flake.modules.nixos."nixosConfigurations/${hostname}"
```

Everything else is already inside `core`, or the host chapter `imports` it.

## `flake.modules.nixos.core` — always on

```text
flake.modules.nixos.core
  flake.modules.nixos.network
    flake.modules.nixos.ssh
    flake.modules.nixos.dns
  flake.modules.nixos.nix
  flake.modules.nixos.users
  (+ disko nixosModule)
```

Also merged **into** `core` (same name, other files):

```text
flake.modules.nixos.core          # locale.nix
flake.modules.nixos.core          # zram-swap.nix
```

`sops` exists as `flake.modules.nixos.sops` but is **not** in `core`
until you have a real `secrets/secrets.yaml`. See INSTALL.md.

## Optional NixOS chapters — host must import them

```text
flake.modules.nixos.bootloader

flake.modules.nixos.home-manager
      → homeManager.core
      → homeManager."homeConfigurations/${hostName}"   # if that host has one

flake.modules.nixos.server-base
flake.modules.nixos.homelab-apps
      # not a registry tree — imports lib/homelab-modules/
      #   options.nix    always.nix    primary.nix    standby.nix
```

## The host chapter — one name, many files merge

```text
flake.modules.nixos."nixosConfigurations/${hostname}"
  # configuration.nix   hostname, imports, role
  # disko.nix           disks + hostId
  # hardware.nix        kernel / CPU
```

Defined today:

```text
flake.modules.nixos."nixosConfigurations/primary"
flake.modules.nixos."nixosConfigurations/standby"
```

This template’s reading list:

```text
primary    bootloader  home-manager  server-base  homelab-apps   role = primary
standby    bootloader  home-manager  server-base  homelab-apps   role = standby
```

## `flake.modules.homeManager.*`

Wired because the NixOS host imported `home-manager`.

```text
flake.modules.homeManager.core
  flake.modules.homeManager.home-manager    # stateVersion
  # also merged into core by:
  #   default.nix, helix.nix
  #   shell/{zsh,starship,atuin,eza,zoxide}.nix
```

This template has no per-host `homeConfigurations/*` files. The shell
still comes from `homeManager.core`. Add
`flake.modules.homeManager."homeConfigurations/primary"` later if the
primary needs extra packages the standby should not share.
