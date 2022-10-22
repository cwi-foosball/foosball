{ config, lib, pkgs, nixpkgs, ... }:
{
  ### This file contains the configuration that most OS (server, frontend…) should share
  # The goal is to configure as much things as possible in this repository, to do minimal changes on the computer
  # See the README.md file to get an introduction on Nix/NixOs

  # For nice integration with the qemu virtual machine
  #virtualisation.qemu.guestAgent.enable = true;
  imports = [ "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" ];
  services.qemuGuest.enable = true;
  virtualisation.qemu.options = lib.mkIf (config ? virtualisation.qemu) [
    "-vga qxl -device virtio-serial-pci -spice port=5930,disable-ticketing=on -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent"

    # To use, first start qemu, it will "hang", in fact in just waits for a client to connect and display the
    # VM.
    # Then run: remote-viewer spice://127.0.0.1:5930
    # https://unix.stackexchange.com/questions/526849/qemu-kvm-using-virt-viewer-vs-remote-viewer
    #"-display spice-app"
  ];
  services.spice-vdagentd.enable = true;
  
  # Ensure /tmp is cleared when restarting the computer
  # boot.cleanTmpDir = builtins.trace (config.virtualisation.qemu.guestAgent) true;
  # attribute qemu missing
  boot.cleanTmpDir = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
    
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ### Basic utilities
    wget
    curl
    htop      # list processes
    git
    pciutils  # To have lspci:
    zip
    ark       # Extract files in dolphin
    file
    nmap
    unzip
    inetutils
    jq        # For displaying json nicely, can be practical to debug
    
    ### For developping/debugging…
    # The best editor
    emacs 
  ];

  nix = {
    # Flake is experimental… but soo cool and quite stable already
     extraOptions = lib.optionalString (config.nix.package == pkgs.nixUnstable)
       "experimental-features = nix-command flakes";
  };

  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
