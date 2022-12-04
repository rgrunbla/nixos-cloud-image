{
  description = "A NixOS ready-to-use cloud image.";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11"; };

  outputs = { self, nixpkgs }:
    with import nixpkgs { system = "x86_64-linux"; }; {
      packages.x86_64-linux.nixos-cloud-image =
        let system = "x86_64-linux";
        in
        import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
          pkgs = nixpkgs.legacyPackages."${system}";
          lib = nixpkgs.lib;
          config = (nixpkgs.lib.nixosSystem {
            inherit system;
            modules =
              [
                ./images/configuration.nix
                ./images/hardware-configuration.nix
                ./images/machine/machine-configuration.nix
              ];
          }).config;
          format = "qcow2";
          diskSize = 2000;
          bootSize = "1024MB";
          name = "base-image";
          partitionTableType = "efi";
          copyChannel = false;
          contents = [
            {
              source = ./images/configuration.nix;
              target = "/etc/nixos/configuration.nix";
            }
            {
              source = ./images/hardware-configuration.nix;
              target = "/etc/nixos/hardware-configuration.nix";
            }
            {
              source = ./images/machine/machine-configuration.nix;
              target = "/etc/nixos/machine/machine-configuration.nix";
            }
          ];
        };
      packages.x86_64-linux.nixos-cloud-image-configuration = stdenv.mkDerivation {
        name = "configuration";
        src = self;
        buildPhase = "";
        installPhase = ''
          mkdir -p $out
          cp -r ./images/* $out
        '';
      };
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.nixos-cloud-image;
    };
}

