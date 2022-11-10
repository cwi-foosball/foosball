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
}
