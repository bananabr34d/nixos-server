# Standby: ZFS `local` on NVMe (OS) + ZFS `tank` mirror on two data disks.
# Dataset names match the primary so syncoid source/target is 1:1.
#
# hostId: generate a *different* one from primary.
#   head -c4 /dev/urandom | od -A none -t x4 | tr -d ' '
{
  flake.modules.nixos."nixosConfigurations/standby" = {
    networking.hostId = "aabbcc02";

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
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "local";
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

      zpool.local = {
        type = "zpool";
        options.ashift = "12";
        rootFsOptions = {
          compression = "zstd";
          atime = "off";
          "com.sun:auto-snapshot" = "false";
          xattr = "sa";
          acltype = "posixacl";
        };
        mountpoint = null;
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            postCreateHook = "zfs snapshot local/root@blank || true";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          var = {
            type = "zfs_fs";
            mountpoint = "/var";
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
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
          documents = {
            type = "zfs_fs";
            mountpoint = "/data/documents";
          };
          media = {
            type = "zfs_fs";
            mountpoint = "/data/media";
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
