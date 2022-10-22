#!/usr/bin/env bash

# The command to start a vm is not long… but this is even quicker to type and ensure we always start from a fresh system
# stop script if error
set -e

keep_data=false
while getopts 'k' OPTION; do
    case "$OPTION" in
        k)
            echo "Keeping the data nixos.qcow file."
            keep_data=true
            ;;
        ?)
        echo "script usage: $(basename \$0) [-k]" >&2
        echo "Set -k to keep the data nixos.qcom file" >&2
        exit 1
        ;;
    esac
done

# Go to the flake folder
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"

echo "Let's try to run the config in a VM!"

# To always start with a fresh system
if [ "$keep_data" = false ]; then
    rm -f nixos.qemu
fi
# Build the configuration
#nixos-rebuild build-vm --flake .#foosballrasp --show-trace
# The new version uses spice for clipboard interaction
nix build .#foosballrasp-with-vm-integration
# Start the VM
echo "We start the VM"
./result/bin/run-nixos-vm
