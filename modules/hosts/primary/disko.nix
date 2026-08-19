# Primary: ext4 OS on NVMe + ZFS tank mirror on two data disks.
#
# Disko **creates** tank. If you already have a tank you care about,
# do not list those disks here — import the pool after first boot and
# declare fileSystems mounts instead. See docs/INSTALL.md.
#
# hostId must be unique and stable. Generate once:
#   head -c4 /dev/urandom | od -A none -t x4 | tr -d ' '
# Never change it after the pool exists.
{
  flake.modules.nixos."nixosConfigurations/primary" = {
    networking.hostId = "aabbcc01";

    disko.devices = {
      disk = {
        nvme = {
          device = "/dev/disk/by-id/nvme-REPLACE-ME-OS";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "umask=0077"
                    "noatime"
                  ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  mountOptions = [ "noatime" ];
                };
              };
            };
          };
        };

        data1 = {
          device = "/dev/disk/by-id/ata-REPLACE-ME-DATA1";
          type = "disk";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
        data2 = {
          device = "/dev/disk/by-id/ata-REPLACE-ME-DATA2";
          type = "disk";
          content = {
            type = "gpt";
            partitions.zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
      };

      zpool.tank = {
        type = "zpool";
        mode = "mirror";
        options.ashift = "12";
        rootFsOptions = {
          compression = "zstd";
          atime = "off";
          "com.sun:auto-snapshot" = "true";
          xattr = "sa";
          acltype = "posixacl";
        };
        mountpoint = null;
        datasets = {
          data = {
            type = "zfs_fs";
            mountpoint = "/data";
          };
          immich = {
            type = "zfs_fs";
            mountpoint = "/data/immich";
          };
          forgejo = {
            type = "zfs_fs";
            mountpoint = "/data/forgejo";
          };
          media = {
            type = "zfs_fs";
            mountpoint = "/data/media";
          };
          documents = {
            type = "zfs_fs";
            mountpoint = "/data/documents";
          };
          public = {
            type = "zfs_fs";
            mountpoint = "/data/public";
          };
          backups = {
            type = "zfs_fs";
            mountpoint = "/data/backups";
          };
        };
      };
    };
  };
}
