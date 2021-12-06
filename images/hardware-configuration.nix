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

    kernelParams = [ "console=tty1" "console=ttyS0,115200" ];

  };
}
