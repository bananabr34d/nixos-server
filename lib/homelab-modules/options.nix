{ lib, ... }:
let
  inherit (lib) mkOption types;
  me = import ../me.nix;
in
{
  options.homelab = {
    role = mkOption {
      type = types.enum [
        "primary"
        "standby"
      ];
      description = ''
        primary: live apps + optional binary cache.
        standby: replication target; apps stay off until you promote it.
      '';
    };

    primaryHost = mkOption {
      type = types.str;
      default = me.primaryHost;
      description = "Hostname of the live primary (syncoid source).";
    };

    tsDomain = mkOption {
      type = types.str;
      default = me.tsDomain;
      description = "Tailscale MagicDNS suffix (from `tailscale status`).";
    };

    syncoidPubKey = mkOption {
      type = types.str;
      default = "";
      description = ''
        Public key of syncoid@standby. Generate on the standby:

          sudo -u syncoid ssh-keygen -t ed25519 -N "" -C syncoid@standby \
            -f /var/lib/syncoid/.ssh/id_ed25519

        Paste the .pub line here and rebuild both hosts.
      '';
    };

    cache.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Harmonia binary cache on the primary. Leave false until you have
        a sops secret `harmonia_key` and have imported the sops module.
      '';
    };

    monitoring = {
      ntfyPort = mkOption {
        type = types.port;
        default = 2586;
      };
      ntfyTopic = mkOption {
        type = types.str;
        default = "homelab";
      };
      zpoolHealthInterval = mkOption {
        type = types.str;
        default = "daily";
      };
    };
  };
}
