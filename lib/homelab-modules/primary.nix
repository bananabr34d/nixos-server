{ config, pkgs, lib, ... }:
let
  h = import ../homelab.nix { inherit config pkgs lib; };
  inherit (h) cfg isPrimary host fqdn mkIf;
  me = import ../me.nix;
in
{
  config = mkIf isPrimary {
    services.samba.settings = {
      media = {
        path = "/data/media";
        "browseable" = "yes";
        "read only" = "no";
        "valid users" = me.username;
      };
      TimeMachine = {
        path = "/data/backups/timemachine";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = me.username;
        "fruit:time machine" = "yes";
        "fruit:time machine max size" = "2T";
      };
    };

    systemd.tmpfiles.rules = [
      "d /data/backups/timemachine 1777 root root -"
      "d /data/${me.username} 0770 ${me.username} users -"
    ];

    services.immich = {
      enable = true;
      mediaLocation = "/data/immich";
      host = "0.0.0.0";
      openFirewall = true;
      machine-learning.enable = true;
      settings.newVersionCheck.enabled = false;
    };

    services.forgejo = {
      enable = true;
      stateDir = "/data/forgejo";
      database.type = "postgres";
      settings.server = {
        DOMAIN = fqdn;
        ROOT_URL = "https://${fqdn}/git/";
        HTTP_PORT = 3000;
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
      3000
      5000
    ];

    # Off until you have sops + a signing key. See docs/INSTALL.md.
    # Do not assign sops.* here at all when the cache is off — the sops
    # module is not imported on first boot, and mkIf still requires the option.
    services.harmonia.cache = lib.mkIf cfg.cache.enable {
      enable = true;
      signKeyPaths = [ config.sops.secrets.harmonia_key.path ];
      settings = {
        bind = "[::]:5000";
        workers = 4;
        priority = 40;
      };
    };

    services.tailscale.permitCertUid = "caddy";

    services.caddy = {
      enable = true;
      virtualHosts."http://${fqdn}" = {
        extraConfig = ''
          redir https://{host}{uri} permanent
        '';
      };
      virtualHosts."${fqdn}" = {
        extraConfig = ''
          encode gzip

          handle_path /git/* {
            reverse_proxy localhost:3000
          }

          handle {
            reverse_proxy localhost:2283
          }

          tls {
            get_certificate tailscale
          }
        '';
      };
      virtualHosts."http://${host}" = {
        extraConfig = ''
          redir https://${fqdn}{uri} permanent
        '';
      };
    };

    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "http://${fqdn}:${toString cfg.monitoring.ntfyPort}";
        listen-http = "0.0.0.0:${toString cfg.monitoring.ntfyPort}";
        upstream-base-url = "https://ntfy.sh";
        auth-default-access = "read-write";
        enable-login = false;
      };
    };

    services.sanoid.datasets = {
      "tank/immich" = {
        hourly = 24;
        daily = 14;
        monthly = 6;
        yearly = 1;
        autosnap = true;
        autoprune = true;
      };
      "tank/forgejo" = {
        hourly = 24;
        daily = 14;
        monthly = 3;
        yearly = 1;
        autosnap = true;
        autoprune = true;
      };
      "tank/documents" = {
        hourly = 12;
        daily = 14;
        monthly = 6;
        autosnap = true;
        autoprune = true;
      };
    };

    # syncoid@standby logs in here to pull ZFS send.
    users.users.syncoid = {
      isSystemUser = true;
      group = "syncoid";
      home = "/var/lib/syncoid";
      createHome = true;
      shell = "${pkgs.shadow}/bin/nologin";
      openssh.authorizedKeys.keys = lib.optional (cfg.syncoidPubKey != "") cfg.syncoidPubKey;
    };
    users.groups.syncoid = { };
  };
}
