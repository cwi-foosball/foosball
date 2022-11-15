#!/usr/bin/env bash
# The command to switch is not long… but this is even quicker to type and does some additional safety checks!

# stop script if error
set -e

# Go to the script folder (useful to have multiple configurations that you can enable in the same system)
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"

# We pin nixpkgs (flake consumes too much RAM for now on a raspberry pi)
echo "## Downloading nixpkgs..."
nixpkgs_with_quotes=$(nix-instantiate --eval --expr 'builtins.fetchTarball {
    url = https://github.com/NixOS/nixpkgs/archive/667e5581d16745bcda791300ae7e2d73f49fff25.tar.gz;
    sha256 = "HYml7RdQPQ7X13VNe2CoDMqmifsXbt4ACTKxHRKQE3Q=";
  }')
# Remote the quotes:
nixpkgs="${nixpkgs_with_quotes//\"}"
sudo nixos-rebuild -I nixos-config=configuration.nix -I "nixpkgs=${nixpkgs}" switch
