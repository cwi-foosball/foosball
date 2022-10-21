{ config, pkgs, lib, ... }:
{
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # apparently also needed for some parts of the pi to work
  hardware.enableRedistributableFirmware = true;

  # Otherwise the hdmi disconnects during the boot and reconnect at the end
  # looks like it is still not enough...
  # Don't enable it with qemu
  boot.initrd.kernelModules = lib.mkIf (!(config ? virtualisation.qemu)) [ "vc4" "bcm2835_dma" "i2c_bcm2835" ];
  
  # Apparently needed for audio (dtparam), 
  # TODO: with older mainline kernels cpu frequency scaling was not supported. Not sure what is the status now.
  # In any case for now let's try everything
  boot.loader.raspberryPi.firmwareConfig = ''
    dtparam=audio=on
    force_turbo=1
  '';
  
  # I get some errors, maybe I should use the rpi3 kernel instead of the mainline one… but
  # K900 said that I should always try to stay as much as possible on mainline… which makes sense.
  # K900 also recommended to use kernel 6.0.2 (default is 5.*),
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Needed for the virtual console to work on the RPi 3, as the default of 16M
  # doesn't seem to be enough. If X.org behaves weirdly (I only saw the cursor)
  # then try increasing this to 256M.
  # https://labs.quansight.org/blog/2020/07/nixos-rpi-wifi-router
  # On some kernels (not sure if it is fixed on 6.0.2) this parameter has priority lower than the deviceTree
  # so if it fails below how to change the device tree
  boot.kernelParams = ["cma=256M"];

  ## This is supposed to do somethink like above, but with higher priority (and different numbers)
  # somehow related, not sure how
  # https://isrc.iscas.ac.cn/gitlab/mirrors/github.com/raspberrypi_linux/-/commit/2d8a0553c9df3d91403a1e4ce2585ef25fd60b0d
  # https://elixir.bootlin.com/linux/latest/source/kernel/dma/contiguous.c#L400
  # hardware.deviceTree.overlays = [
  #   {
  #     name = "rpi4-cma-overlay";
  #     dtsText = ''
  #         // SPDX-License-Identifier: GPL-2.0
  #         /dts-v1/;
  #         /plugin/;
  #         / {
  #           compatible = "brcm,bcm2711";
  #           fragment@0 {
  #             target = <&cma>;
  #             __overlay__ {
  #               size = <(512 * 1024 * 1024)>;
  #             };
  #           };
  #         };
  #       '';
  #   }
  # ];
  
}
