{ config, lib, pkgs, ... }:
{
  ### This file contains the configuration for the OS's that use a GUI (so not servers)
  # The goal is to configure as much things as possible in this repository, to do minimal changes on the computer
  # See the README.md file to get an introduction on Nix/NixOs

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # XKB's configuration also applies in the console
  console.useXkbConfig = true;

  services.xserver.libinput = {
    enable = true;
  };

   
  # Useful to make home manager work
  programs.dconf.enable = true;

  # pipewire is much better than pulseaudio
  # Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
  sound.enable = false;

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    let
      # Create a new desktop entry to start the foosball game
      startFoosball = pkgs.makeDesktopItem {
        name = "foosball";
        desktopName = "Foosball!";
        exec = if lib.strings.hasPrefix config.services.CWIFoosballKiosk.kiosk.urlServer "localhost"
                  && config.services.CWIFoosballKiosk.kiosk.enableLoadingPage
               then
                 "chromium --start-fullscreen ${pkgs.cwi-foosball-web}/share/cwi-foosball-web/index.html"
               else
                 "chromium --start-fullscreen ${config.services.CWIFoosballKiosk.kiosk.urlServer}";
        icon = let icon = ./images/foosball.png; in "${icon}";
      };
      # And autostart it!
      startFoosballAutostart = pkgs.makeAutostartItem {
        name = "foosball";
        package = startFoosball;
      };
    in
      with pkgs; [
        ### Basic utilities
        gparted

        ### To display the foosball page
        firefox # the website seems to fail with firefox
        (chromium.override {
          # https://github.com/NixOS/nixpkgs/issues/200497
          commandLineArgs = [
            "--use-gl=desktop"
          ];
        })

        ### Generic tools that might be useful
        pavucontrol # always practical to setup sound

        # To provide an entry to start the foosball game
        startFoosball
        # To start it automatically
        startFoosballAutostart
      ];
}
