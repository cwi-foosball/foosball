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

  # Install KDE (yes, I don't like i3, I prefer when stuff is easily discoverable…
  # Let's see how KDE runs on a rasp!
  services.xserver.displayManager = {
    sddm = {
      enable = true;
      autoLogin.relogin = true;
    };
    autoLogin = {
      enable = true;
      user = "pi";
    };    
  };
  services.xserver.desktopManager.plasma5.enable = true;
  
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
        exec = "chromium --start-fullscreen https://foosball.cwi.nl";
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
        ark       # Extract files in dolphin

        ### To display the foosball page
        firefox
        chromium

        ### Generic tools that might be useful
        pavucontrol # always practical to setup sound
        okular      # KDE: display pdf
        spectacle   # KDE: take screenshots
        gwenview    # KDE: display pictures

        ### To display icon in systray KDE... and seems to solve the volume key issues!
        # kmix # I prefer plasma-pa applet: when scrolling on kmix the sound is played on internal card instead of default sink...
        plasma-pa
        pulseaudioFull # needed to provide additional tools (pipewire can be configured via pulseaudio commands)

        # To provide an entry to start the foosball game
        startFoosball
        # To start it automatically
        startFoosballAutostart
      ];

  # Default configuration for KDE
  # Note that you can obtain the name of the options by creating a git repository for the .config file
  # and doing a diff after the change on the GUI interface
  environment.etc = {
    "xdg/ksmserverrc".text =
      ''
        [General]
        loginMode=emptySession
      '';
    # To avoid asking password when goes to sleep we disable the screen locker
    "xdg/kscreenlockerrc".text =
      ''
        [Daemon]
        Autolock=false
        LockOnResume=false
      '';
    # Enable dark interface
    "xdg/kdeglobals".text =
      ''
        [KDE]
        LookAndFeelPackage=org.kde.breezedark.desktop
      '';
    # Compositing takes too much energy
    # https://www.youtube.com/watch?v=QIrGVzAu7y8
    "xdg/kwinrc".text =
      ''
        [Compositing]
        Enabled=false
      '';
  };  
}
