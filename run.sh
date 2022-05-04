#!/usr/bin/env nix-shell
#! nix-shell -i bash -p qemu

root=$(find ./ -name 'nixos.*');

echo "${boot} ${root}"
echo '`Ctrl-a h` to get help on the monitor';
echo '`Ctrl-a x` to exit';

qemu-kvm \
    -bios UEFI/OVMF.fd \
    -enable-kvm \
    -nographic \
    -cpu max \
    -m 4G \
    -drive file=$root,snapshot=on,index=0,media=disk \
    -boot c \
    -net user \
    -net nic \
    -msg timestamp=on
