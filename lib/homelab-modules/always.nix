{ config, pkgs, lib, ... }:
let
  h = import ../homelab.nix { inherit config pkgs lib; };
  inherit (h) cfg host smartdNtfyMailer zpoolHealthCheck;
  me = import ../me.nix;
in
{
  config = {
    services.samba.settings = {
      public = {
        path = "/data/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = me.username;
      };
      ${me.username} = {
        path = "/data/${me.username}";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = me.username;
        "create mask" = "0660";
        "directory mask" = "0770";
      };
      documents = {
        path = "/data/documents";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = me.username;
        "create mask" = "0660";
        "directory mask" = "0770";
      };
    };

    services.sanoid = {
      enable = true;
      interval = "hourly";
    };

    services.smartd = {
      enable = true;
      autodetect = true;
      notifications.wall.enable = false;
      notifications.mail = {
        enable = true;
        recipient = "ntfy";
        mailer = smartdNtfyMailer;
      };
    };

    environment.systemPackages = [
      pkgs.smartmontools
      pkgs.lzop
      pkgs.mbuffer
    ];

    systemd.tmpfiles.rules = [
      "d /var/lib/homelab 0755 root root -"
    ];

    systemd.services.homelab-zpool-health = {
      description = "Alert via ntfy if zpool status -x is not healthy";
      after = [ "zfs-import.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = zpoolHealthCheck;
      };
    };
    systemd.timers.homelab-zpool-health = {
      description = "Periodic zpool health → ntfy";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.monitoring.zpoolHealthInterval;
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
    };
  };
}
