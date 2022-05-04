{ config, lib, pkgs, ... }: {

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  boot = {
    kernelParams = [ "console=ttyS0" ];
    growPartition = true;
    loader.grub = {
      version = 2;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      font = "${pkgs.grub2_efi}/share/grub/unicode.pf2";
      extraConfig = ''
        serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
        terminal_output serial
        terminal_input serial
      '';
    };
     initrd = {
        network.enable = false;
        availableKernelModules = [
          "virtio_net"
          "virtio_pci"
          "virtio_mmio"
          "virtio_blk"
          "virtio_scsi"
          "kvm-amd"
          "kvm-intel"
          "xhci_pci"
          "ehci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
          "9p"
          "9pnet"
          "9pnet_virtio"
        ];
      };
  };
}
