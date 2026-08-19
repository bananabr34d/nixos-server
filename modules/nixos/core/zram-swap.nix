# Compressed RAM as swap. No extra disk partition, safe on LUKS+btrfs.
# Hibernate (suspend-to-disk) is not supported — that needs a real swap
# device at least as big as RAM. Suspend-to-RAM + lock is fine.
#
# After switch: `zramctl` / `swapon --show` should list /dev/zram0.
{
  flake.modules.nixos.core = {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };
  };
}
