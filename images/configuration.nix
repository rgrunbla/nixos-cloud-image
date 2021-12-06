{ config, pkgs, lib, options, fetchurl, ... }:

{
  # Mount tmpfs on /tmp
  boot.tmpOnTmpfs = lib.mkDefault true;

  # Install basic packages
  environment.systemPackages = with pkgs; [ ncdu ];

  # Allow proxmox to reboot the images
  services.acpid.enable = true;

  # Enable the serial console on ttyS0
  systemd.services."serial-getty@ttyS0".enable = true;

  # Size reduction
  # TODO: recompile the kernel to remove everything that's useless
  # e.g. wireless modules, drivers, firmwares, ethernet drivers, …

  ## Remove Xlibs
  environment.noXlibs = true;

  ## Limit the locales we use
  i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];

  ## Remove polkit. It depends on spidermonkey !
  security.polkit.enable = false;

  ## Remove documentation
  documentation.enable = false;
  documentation.nixos.enable = false;
  documentation.man.enable = false;
  documentation.info.enable = false;
  documentation.doc.enable = false;

  ## Disable udisks, sounds, …
  services.udisks2.enable = false;
  xdg.sounds.enable = false;

  ## Optimize store
  nix.autoOptimiseStore = true;

  # Enable time sync
  services.timesyncd.enable = true;

  # Enable the firewall
  networking = {
    useDHCP = false;
    usePredictableInterfaceNames = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # Enable Cloud Init
  services.cloud-init.enable = true;

  # SSH
  services.sshd.enable = true;
  services.openssh = { passwordAuthentication = false; };

  # compatible NixOS release
  system.stateVersion = "21.11";
}
