{
  flake.modules.nixos.nix =
    { pkgs, ... }:
    let
      me = import ../../../../lib/me.nix;
    in
    {
      nix = {
        gc = {
          automatic = true;
          options = "--delete-older-than 8d";
          dates = "weekly";
          persistent = true;
        };

        optimise.automatic = true;

        settings = {
          experimental-features = "nix-command flakes";
          max-jobs = "auto";
          use-xdg-base-directories = true;
          http-connections = 128;
          max-substitution-jobs = 128;
          log-lines = 25;
          min-free = 128000000;
          max-free = 1000000000;
          keep-outputs = true;
          keep-derivations = true;
          auto-optimise-store = true;
          warn-dirty = false;
          connect-timeout = 5;
          trusted-users = [
            "root"
            me.username
          ];
          builders-use-substitutes = true;
          fallback = true;

          # After Harmonia is on the primary, prepend:
          #   "http://${me.primaryHost}:5000"
          # and that cache's public key. Until then, only the public cache.
          substituters = [ "https://cache.nixos.org" ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ];
        };
      };

      environment.systemPackages = with pkgs; [
        just
        nh
        nix-output-monitor
        nvd
      ];
    };
}
