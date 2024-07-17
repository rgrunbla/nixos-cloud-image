{ config, pkgs, lib, options, fetchurl, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./machine/machine-configuration.nix
    ];

  # Mount tmpfs on /tmp
  # boot.tmpOnTmpfs = lib.mkDefault true;

  # Install basic packages
  environment.systemPackages = with pkgs; [ ncdu ];

  # Allow proxmox to reboot the images
  services.acpid.enable = lib.mkDefault true;

  # Enable Qemu Agent
  services.qemuGuest.enable = lib.mkDefault true;

  # Enable the serial console on ttyS0
  systemd.services."serial-getty@ttyS0".enable = true;

  # Size reduction
  # TODO: recompile the kernel to remove everything that's useless
  # e.g. wireless modules, drivers, firmwares, ethernet drivers, …

  ## Remove Xlibs
  ## Problem : triggers the rebuild of qemu* which takes one hour or so
  # environment.noXlibs = lib.mkDefault true;

  ## Limit the locales we use
  i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];

  ## Remove polkit. It depends on spidermonkey !
  security.polkit.enable = lib.mkDefault false;

  ## Remove documentation
  documentation.enable = lib.mkDefault false;
  documentation.nixos.enable = lib.mkDefault false;
  documentation.man.enable = lib.mkDefault false;
  documentation.info.enable = lib.mkDefault false;
  documentation.doc.enable = lib.mkDefault false;

  ## Disable udisks, sounds, …
  services.udisks2.enable = lib.mkDefault false;
  xdg.sounds.enable = lib.mkDefault false;

  ## Optimize store
  nix.settings = {
    auto-optimise-store = lib.mkDefault true;
  };

  # Enable time sync
  services.timesyncd.enable = lib.mkDefault true;

  # Enable the firewall
  networking = {
    useDHCP = lib.mkDefault false; # We will use cloud init configuration for networking
    usePredictableInterfaceNames = lib.mkDefault false;
    firewall = {
      enable = lib.mkDefault true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # Enable flakes
  nix = {
    extraOptions = lib.mkDefault ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
    '';

    # Ensure the NIX_PATH Variable is set up correctly
    nixPath = lib.mkDefault [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  # Enable Cloud Init
  services.cloud-init = {
    enable = lib.mkDefault true;
    network.enable = lib.mkDefault true;
  };

  # SSH
  services.sshd.enable = lib.mkDefault true;
  services.openssh.settings = { PasswordAuthentication = lib.mkDefault false; };

  # compatible NixOS release
  system.stateVersion = "24.05";

  # Root Password is "root"
  users.users.root.password = lib.mkDefault "root";
}
