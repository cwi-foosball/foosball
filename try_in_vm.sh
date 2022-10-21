#!/usr/bin/env bash

# Go to the flake folder
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"

echo "Let's try to run the config in a VM!"

# To always start with a fresh system
rm -f nixos.qemu
# Build the configuration
nixos-rebuild build-vm --flake .#foosballrasp
# Start the VM
./result/bin/run-nixos-vm
