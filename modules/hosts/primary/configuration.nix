{ inputs, ... }:
{
  nixosHosts.primary = {
    system = "x86_64-linux";
  };

  flake.modules.nixos."nixosConfigurations/primary" = {
    imports = with inputs.self.modules.nixos; [
      bootloader
      home-manager
      server-base
      homelab-apps
    ];

    networking.hostName = "primary";
    homelab.role = "primary";
    # After you generate the syncoid key on standby, paste the .pub here:
    # homelab.syncoidPubKey = "ssh-ed25519 AAAA... syncoid@standby";
    #
    # Harmonia: import sops (see docs/INSTALL.md), then:
    #   homelab.cache.enable = true;
    #   sops.secrets.harmonia_key = { owner = "root"; group = "root"; mode = "0400"; };
  };
}
