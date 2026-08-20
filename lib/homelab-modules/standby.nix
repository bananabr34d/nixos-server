{
  config,
  pkgs,
  lib,
  ...
}:
let
  h = import ../homelab.nix { inherit config pkgs lib; };
  inherit (h)
    cfg
    isStandby
    syncoidFailureNotify
    mkIf
    ;
in
{
  config = mkIf isStandby {
    services.immich.enable = false;
    services.forgejo.enable = false;
    services.caddy.enable = false;
    services.harmonia.cache.enable = false;
    services.ntfy-sh.enable = false;
    services.samba.enable = lib.mkForce false;
    services.avahi.enable = lib.mkForce false;

    # Receive-only: prune, do not snapshot. Autosnap names would collide
    # with the primary and break syncoid receive.
    services.sanoid.datasets = {
      "tank/immich" = {
        hourly = 48;
        daily = 30;
        monthly = 6;
        yearly = 1;
        autosnap = false;
        autoprune = true;
      };
      "tank/forgejo" = {
        hourly = 48;
        daily = 14;
        monthly = 3;
        autosnap = false;
        autoprune = true;
      };
      "tank/documents" = {
        hourly = 24;
        daily = 14;
        monthly = 6;
        autosnap = false;
        autoprune = true;
      };
    };

    services.syncoid = {
      enable = true;
      interval = "daily";
      user = "syncoid";
      group = "syncoid";
      sshKey = "/var/lib/syncoid/.ssh/id_ed25519";
      localTargetAllow = [
        "bookmark"
        "hold"
        "receive"
        "rollback"
        "destroy"
        "mount"
        "create"
        "mountpoint"
        "compression"
        "recordsize"
      ];
      commands = {
        immich = {
          source = "syncoid@${cfg.primaryHost}:tank/immich";
          target = "tank/immich";
          recursive = true;
        };
        forgejo = {
          source = "syncoid@${cfg.primaryHost}:tank/forgejo";
          target = "tank/forgejo";
          recursive = true;
        };
        documents = {
          source = "syncoid@${cfg.primaryHost}:tank/documents";
          target = "tank/documents";
          recursive = true;
        };
      };
    };

    environment.etc."ssh/ssh_config.d/50-syncoid.conf".text = ''
      Host ${cfg.primaryHost} ${cfg.primaryHost}.${cfg.tsDomain}
        User syncoid
        StrictHostKeyChecking accept-new
        UserKnownHostsFile /var/lib/syncoid/.ssh/known_hosts
        IdentityFile /var/lib/syncoid/.ssh/id_ed25519
        IdentitiesOnly yes
    '';

    systemd.tmpfiles.rules = [
      "d /var/lib/syncoid 0750 syncoid syncoid -"
      "d /var/lib/syncoid/.ssh 0700 syncoid syncoid -"
    ];

    systemd.services."homelab-ntfy-failure@" = {
      description = "Post systemd unit failure %i to ntfy";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${syncoidFailureNotify} %i";
      };
    };

    systemd.services.syncoid-immich.unitConfig.OnFailure = "homelab-ntfy-failure@%N.service";
    systemd.services.syncoid-forgejo.unitConfig.OnFailure = "homelab-ntfy-failure@%N.service";
    systemd.services.syncoid-documents.unitConfig.OnFailure = "homelab-ntfy-failure@%N.service";
  };
}
