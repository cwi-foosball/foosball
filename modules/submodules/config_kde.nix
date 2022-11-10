{

  # Install KDE (yes, I don't like i3, I prefer when stuff is easily discoverable…
  # Let's see how KDE runs on a rasp!
  # Ok it's too slow…
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

  environment.systemPackages = [
    ark # extract files in dolphin
    okular      # KDE: display pdf
    spectacle   # KDE: take screenshots
    gwenview    # KDE: display pictures

    ### To display icon in systray KDE... and seems to solve the volume key issues!
    # kmix # I prefer plasma-pa applet: when scrolling on kmix the sound is played on internal card instead of default sink...
    plasma-pa
    pulseaudioFull # needed to provide additional tools (pipewire can be configured via pulseaudio commands)

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
