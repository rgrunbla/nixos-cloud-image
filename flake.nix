{
  description = "A NixOS ready-to-use cloud image.";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11"; };

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
              ];
          }).config;
          format = "qcow2";
          diskSize = 32000;
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
          ];
        };
      packages.x86_64-linux.nixos-cloud-image-configuration = stdenv.mkDerivation {
        name = "configuration";
        src = self;
        buildPhase = "";
        installPhase = ''
          mkdir -p $out
          install -t $out ./images/configuration.nix
          install -t $out ./images/hardware-configuration.nix
          install -t $out ./images/machine-configuration.nix
        '';
      };
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.nixos-cloud-image;
    };
}
