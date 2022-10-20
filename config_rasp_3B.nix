{ config, pkgs, lib, ... }:
{
  ### This file contains stuff specific for the raspberry pi
  imports = [
    ./hardware-configuration.nix
  ];
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

}
