# App stack. Import and set homelab.role = "primary" | "standby".
# Implementation lives under lib/homelab-modules/ (outside import-tree
# so these files are ordinary NixOS modules, not flake-parts modules).
{
  flake.modules.nixos.homelab-apps = {
    imports = [
      ../../../../lib/homelab-modules/options.nix
      ../../../../lib/homelab-modules/always.nix
      ../../../../lib/homelab-modules/primary.nix
      ../../../../lib/homelab-modules/standby.nix
    ];
  };
}
