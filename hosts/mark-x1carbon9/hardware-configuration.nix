# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    inputs.hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices = {
    nixos-enc = {
      device = "/dev/nvme0n1p2";
      preLVM = true;

      # According to the documentation this setting has security implications.
      # https://search.nixos.org/options?channel=unstable&show=boot.initrd.luks.devices.%3Cname%3E.allowDiscards&from=0&size=50&sort=relevance&type=packages&query=boot.initrd.luks.devices
      # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)
      allowDiscards = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c593c919-d842-4879-a045-c54d0f6e0c32";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B932-F428";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/414f0934-147e-4feb-a501-e81ce6798de8"; }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  hardware.bluetooth.enable = true;

  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
