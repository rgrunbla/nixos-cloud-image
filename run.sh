#!/usr/bin/env nix-shell
#! nix-shell -i bash -p qemu cdrkit

root=nixos.qcow2
genisoimage -output cidata.iso -V cidata -r -J user-data meta-data

qemu-kvm \
    -bios UEFI/OVMF.fd \
    -enable-kvm \
    -nographic \
    -cpu max \
    -m 4G \
    -drive file=nixos.qcow2,snapshot=on,index=0,media=disk \
    -drive file=cidata.iso,snapshot=on,index=1,media=disk \
    -boot c \
    -net user \
    -nic user,hostfwd=tcp::2222-:22 \
    -net nic \
    -msg timestamp=on
