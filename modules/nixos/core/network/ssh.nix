{
  flake.modules.nixos.ssh = {
    programs.ssh.startAgent = true;

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    # Optional overlay network. First boot: `sudo tailscale up` and log in.
    services.tailscale.enable = true;
    networking.firewall.allowedUDPPorts = [ 41641 ];
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
