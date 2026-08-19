# Shared base for ZFS data-plane servers. Hardware-agnostic.
# Apps + primary/standby role: import homelab-apps and set homelab.role.
{
  flake.modules.nixos.server-base =
    { config, lib, ... }:
    let
      me = import ../../../../lib/me.nix;
      dataMountPaths = [
        "/data"
        "/data/immich"
        "/data/forgejo"
        "/data/media"
        "/data/documents"
        "/data/public"
        "/data/backups"
      ];
    in
    {
      boot.supportedFilesystems = [ "zfs" ];
      boot.initrd.supportedFilesystems = [ "zfs" ];
      boot.zfs.devNodes = "/dev/disk/by-id";

      # Single owner per pool. After a crash ZFS may refuse import
      # without -f; these flags make boot retry. Do not use if you
      # import the same pool on two machines at once.
      boot.zfs.forceImportRoot = true;
      boot.zfs.forceImportAll = true;

      fileSystems = lib.genAttrs dataMountPaths (_path: {
        options = lib.mkAfter [
          "nofail"
          "x-systemd.mount-timeout=90s"
          "x-systemd.after=zfs-import-tank.service"
        ];
      });

      services.zfs = {
        autoScrub.enable = true;
        autoScrub.interval = "weekly";
        trim.enable = true;
      };

      boot.loader.timeout = 0;
      services.openssh.settings.PasswordAuthentication = false;

      virtualisation.podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      services.samba = {
        enable = true;
        openFirewall = true;
        settings.global = {
          "workgroup" = "WORKGROUP";
          security = "user";
          "server min protocol" = "SMB2";
          "vfs objects" = "catia fruit streams_xattr";
          "fruit:aapl" = "yes";
          "fruit:encoding" = "native";
          "fruit:metadata" = "stream";
          "fruit:model" = "MacSamba";
          "fruit:posix_rename" = "yes";
          "fruit:veto_appledouble" = "no";
          "fruit:nfs_aces" = "no";
          "map to guest" = "bad user";
          "ea support" = "yes";
        };
      };

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };

      system = {
        autoUpgrade.enable = false;
        stateVersion = "26.05";
      };

      users.users.${me.username}.extraGroups = [ "wheel" ];
    };
}
