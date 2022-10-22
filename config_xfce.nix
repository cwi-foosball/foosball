{ config, pkgs, ... }:
{ 
  services.xserver = {
    enable = true;
    desktopManager.xfce = {
      enable = true;
      enableScreensaver = false;
    };
    displayManager = {
      defaultSession = "xfce";
      autoLogin = {
        enable = true;
        user = "pi";
      };
    };
  };
  programs.thunar.plugins = with pkgs; [
    xfce.thunar-archive-plugin
  ];
  environment.systemPackages = with pkgs; [
    xfce.xfce4-whiskermenu-plugin
    orchis-theme
  ];
  # # Nice effects apparently, check if not too heavy
  # services.picom = {
  #   enable = true;
  #   fade = true;
  #   inactiveOpacity = 0.9;
  #   shadow = true;
  #   fadeDelta = 4;
  # };

  # Default configuration for XFCE using kiosk mode (forbids user to change some properties)
  # https://wiki.xfce.org/howto/kiosk_mode
  # You can also get new setting by creating a git repository in .config to see what changes when you graphically
  # change something
  environment.etc = {
    "xdg/xfce4/kiosk/kioskrc".text =
      ''
        [xfce4-session]
        SaveSession=NONE
      '';
  };  

}
