{ config, pkgs, ... }:
{ 
  services.xserver = {
    enable = true;
    desktopManager = {
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
  };
  programs.thunar.plugins = [
    pkgs.xfce.thunar-archive-plugin
  ];
  # environment.systemPackages = with pkgs; [
  #   orchis-theme
  # ];
  # # Nice effects apparently, check if not too heavy
  # services.picom = {
  #   enable = true;
  #   fade = true;
  #   inactiveOpacity = 0.9;
  #   shadow = true;
  #   fadeDelta = 4;
  # };
}
