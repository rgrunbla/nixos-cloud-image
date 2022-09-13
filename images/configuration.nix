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
  services.acpid.enable = true;

  # Enable Qemu Agent
  services.qemuGuest.enable = true;

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
    useDHCP = false; # We will use cloud init configuration for networking
    usePredictableInterfaceNames = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # Enable Cloud Init
  services.cloud-init = {
    enable = lib.mkDefault true;
    network.enable = true;

    # This is the default where we remove        cloud_init_modules: - users-groups - update_etc_hosts
    config = ''
      system_info:
        distro: nixos
        network:
          renderers: [ 'networkd' ]
      users:
         - root

      disable_root: false
      preserve_hostname: false

      cloud_init_modules:
       - migrator
       - seed_random
       - bootcmd
       - write-files
       - growpart
       - resizefs
       - ca-certs
       - rsyslog

      cloud_config_modules:
       - disk_setup
       - mounts
       - ssh-import-id
       - set-passwords
       - timezone
       - disable-ec2-metadata
       - runcmd
       - ssh

      cloud_final_modules:
       - rightscale_userdata
       - scripts-vendor
       - scripts-per-once
       - scripts-per-boot
       - scripts-per-instance
       - scripts-user
       - ssh-authkey-fingerprints
       - keys-to-console
       - phone-home
       - final-message
       - power-state-change
    '';
  };

  # SSH
  services.sshd.enable = true;
  services.openssh = { passwordAuthentication = lib.mkDefault false; };

  # compatible NixOS release
  system.stateVersion = "21.11";

  # Root Password is "root"
  users.users.root.password = lib.mkDefault "root";


  # Automatic upgrades, once a day, with possible reboots
  system.autoUpgrade = {
    randomizedDelaySec = "45min";
    enable = lib.mkDefault true;
    allowReboot = true;
    rebootWindow = {
      lower = "03:00";
      upper = "05:00";
    };
  };
}
