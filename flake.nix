{
  description = "A NixOS ready-to-use cloud image.";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11"; };

  outputs = { self, nixpkgs }:
    with import nixpkgs { system = "x86_64-linux"; }; {
      packages.x86_64-linux.nixos-cloud-image = let system = "x86_64-linux";
      in import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
        pkgs = nixpkgs.legacyPackages."${system}";
        lib = nixpkgs.lib;
        config = (nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            [ ./images/configuration.nix ./images/hardware-configuration.nix ];
        }).config;
        format = "qcow2";
        diskSize = 2048;
        name = "base-image";
      };
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.nixos-cloud-image;
    };
}
