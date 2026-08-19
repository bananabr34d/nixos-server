{
  flake.modules.nixos."nixosConfigurations/primary" =
    { config, lib, ... }:
    {
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
      ];
      boot.kernelModules = [ "kvm-amd" ];
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      networking.useDHCP = lib.mkDefault true;
    };
}
