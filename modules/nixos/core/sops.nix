{
  flake.modules.nixos.sops =
    { pkgs, ... }:
    {
      sops = {
        defaultSopsFile = ../../../secrets/secrets.yaml;
        # Private age key on the installed system. Never commit this file.
        # During install, copy it to /mnt/var/lib/sops-nix/key.txt first.
        age.keyFile = "/var/lib/sops-nix/key.txt";
      };

      environment.systemPackages = [
        pkgs.sops
        pkgs.age
      ];
    };
}
