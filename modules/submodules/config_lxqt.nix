# Lxqt seems to be much more fluid than xfce… but this may not be really accurate as I think I tested lxqt with
# less cma and an older kernel. Anyway it looks great as well with the KDE look
# (to enable manually in apparence… for now).
{ config, pkgs, ... }:
{ 
  services.xserver = {
    enable = true;
    desktopManager.lxqt = {
      enable = true;
    };
    displayManager = {
      defaultSession = "lxqt";
      autoLogin = {
        enable = true;
        user = "pi";
      };
    };
  };
  
  ######### Configuration and theme
  # Nicer configuration for Lxqt. You can also learn new setting by creating a git repository in .config to
  # see what changes when you graphically change something.
  environment.etc = {
    # Theme plasma for the widgets, and noto font looks much more modern
    "xdg/lxqt/lxqt.conf".text =
      ''
        [General]
        icon_follow_color_scheme=true
        theme=KDE-Plasma
        [Qt]
        font="Noto Sans,11,-1,5,50,0,0,0,0,0"
      '';
    "xdg/lxqt/panel.conf".text = ''
      [quicklaunch]
      alignment=Left
      apps\1\desktop=/run/current-system/sw/share/applications/foosball.desktop
      apps\2\desktop=/run/current-system/sw/share/applications/chromium-browser.desktop
      apps\size=2
      type=quicklaunch
    '';
    # Nicer cursor
    "xdg/lxqt/session.conf".text = ''
      [Mouse]
      cursor_theme=Vimix
    '';

  };
  fonts.fonts = with pkgs; [
    noto-fonts
  ];  
  # Default configuration for Openbox (default WM).
  environment.etc = {
    # Openbox theme. Warning this applies only for new users as if the user has an rc.xml file the system one is
    # not used… and this file is created at startup. Mistral will be install below.
    "xdg/openbox/rc.xml".source = ./themes/config_openbox_rc.xml;
  };
  
  ######### Install themes
  # Configurations and theming
  # We will keep things simple, but some great themes are:
  # - https://www.reddit.com/r/unixporn/comments/gey3sx/openbox_another_nord_rice/?utm_source=share&utm_medium=mweb (https://github.com/owl4ce/dotfiles. picom, tint2, rofi, )
  environment.systemPackages =
    let
      # Theme from https://www.box-look.org/p/1017738/
      mistralTheme = pkgs.stdenv.mkDerivation {
        name = "mistral";
        src = ./themes/Mistral.obt;
        dontUnpack = true;
        installPhase = ''
          mkdir -p $out/share/themes/
          tar xf "$src" -C $out/share/themes/
        '';
      };
      # Theme for cursor https://www.gnome-look.org/p/1358330
      # see also https://www.gnome-look.org/p/1393084
      vimix_cursor = pkgs.stdenv.mkDerivation {
        name = "vimix";
        src = ./themes/01-Vimix-cursors.tar.xz;
        installPhase = ''
          mkdir -p $out/share/icons/Vimix
          cp -r * $out/share/icons/Vimix
        '';
      };
    in [
      mistralTheme
      vimix_cursor
    ];
}
