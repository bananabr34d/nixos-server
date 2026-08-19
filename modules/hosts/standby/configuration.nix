{ inputs, ... }:
{
  nixosHosts.standby = {
    system = "x86_64-linux";
  };

  flake.modules.nixos."nixosConfigurations/standby" = {
    imports = with inputs.self.modules.nixos; [
      bootloader
      dev
      server-base
      homelab-apps
    ];

    networking.hostName = "standby";
    homelab.role = "standby";
    # homelab.primaryHost comes from lib/me.nix (default "primary")
  };
}
