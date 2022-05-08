# Nixos Cloud Image

This repository contains a setup to create a Nixos "Cloud Image" which uses cloud init for its configuration.

To create the image, run

    $ nix build .#

in the cloned repository, which will result in a `nixos.qcow2` image in the `result/` directory.

You can then copy this image to the current directory, and test with the [./run.sh](run.sh) script which will generate a cloud-init disk image from the [./meta-data](meta-data) and [./user-data](user-data) files, and boot it using qemu.