{ config, inputs, ... }:
{
  flake.modules.nixos.core.imports = with config.flake.modules.nixos; [
    inputs.disko.nixosModules.disko
    # Import `sops` + the sops-nix module when secrets/secrets.yaml exists.
    # Harmonia needs it; first boot works without it (cache stays off).

    network
    nix
    users
  ];
}
