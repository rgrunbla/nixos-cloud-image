# Nixos Cloud Image

This repository contains a setup to create a Nixos "Cloud Image" which uses cloud init for its configuration.

To create the image, run

    $ nix build .#

in the cloned repository, which will result in a `nixos.qcow2` image in the `result/` directory.

You can then copy this image to the current directory, and test with the [./run.sh](run.sh) script which will generate a cloud-init disk image from the [./meta-data](meta-data) and [./user-data](user-data) files, and boot it using qemu.

This image is only compatible with **UEFI** systems.

## Use with proxmox

You can use this image as a template with proxmox:

```
sudo qm create 9000 -name nixos-cloud -memory 1024 -net0 virtio,bridge=vmbr1 -cores 1 -sockets 1
sudo qm importdisk 9000 nixos.qcow2 local
sudo qm set 9000 -scsihw virtio-scsi-pci -scsi0 local:9000/vm-9000-disk-0.raw
sudo qm set 9000 -serial0 socket
sudo qm set 9000 -boot c -bootdisk scsi0
sudo qm set 9000 -agent 1
sudo qm set 9000 -hotplug disk,network,usb
sudo qm set 9000 -vcpus 1
sudo qm set 9000 --bios ovmf
sudo qm set 9000 -scsi1 local:cloudinit
sudo qm template 9000
```