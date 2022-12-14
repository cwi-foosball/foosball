#!/usr/bin/env bash
# The command to switch is not long… but this is even quicker to type and does some additional safety checks!

# stop script if error
set -e

# Go to the flake folder
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"

# Test the current folder to be sure we are on the raspberry pi (you don't want to override the system)
if [ -f "/etc/nixos/modules/foosballKiosk.nix" ] 
then
    echo "You seem to be on the right machine"
else
    echo "WARNING: you seem to be on a different machine than the foosball one (can't find /etc/nixos/modules/foosballKiosk.nix)"
    echo "This will reinstall the current system to turn it into a foosball client machine… is it what you want?"
    read -p "Continue (y/n)? " choice
    case "$choice" in 
        y|Y ) echo "Ok it's your choice…";;
        n|N ) exit 1;;
        * ) exit 1;;
    esac
fi
echo "Let's install the new system!"
# Actually you don't even need this if the flake is in /etc/nixos/flake.nix and the current host
# is foosballrasp. But it may not be the case for the first install for instance
sudo nixos-rebuild switch --flake .#foosballrasp
