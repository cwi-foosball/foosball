## This module contains all configurations for the raspberry client 'kiosk' (so no web server here, only chromium…)
{ pkgs, lib, config, ... }:
with lib;
{
  # Define new options to easily turn on/off parts of the module on any NixOs system
  # and to configure it in a few lines.
  # Read their 'description' field to see what they are useful for.
  options.services.CWIFoosballKiosk = {
    enableEverything = mkEnableOption "all modules of the raspberry kiosk (sets rasp3b.enable etc… to true).";
    rasp3b = {
      enable = mkEnableOption "configuration specific to the rasp 3b.";
    };
    login = {
      enable = mkEnableOption "login module.";
    };
    genericSystem = {
      enable = mkEnableOption "generic system.";
    };
    kiosk = {
      enable = mkEnableOption "kiosk: stuff related to x11 and chromium package that start automatically.";
      urlServer = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
        example = "https://foosball.cwi.nl";
        description = "Url of the server to open in the browser";
      };
    };
    xfce = {
      enable = mkEnableOption "stuff related to xfce.";
    };
  };
  
  # Configure the system depending on the options chosen by the end user (defined above)
  # To get a list of all available NixOs options, use
  # https://search.nixos.org/options or the nixpkg/nixos/nix manuals
  config = let
    # this is a bit long to type, here is a shortcut
    cfg = config.services.CWIFoosballKiosk;
  in 
    lib.mkMerge [
      # If enableEverything is true… enable everything.
      (mkIf cfg.enableEverything {
        services.CWIFoosballKiosk = {
          rasp3b.enable = true;
          login.enable = true;
          genericSystem.enable = true;
          kiosk.enable = true;
          xfce.enable = true;
        };
      })
      (mkIf cfg.rasp3b.enable (import ./config_rasp_3B.nix {inherit config lib pkgs;}))
      (mkIf cfg.login.enable (import ./config_login_rasp.nix {inherit config lib pkgs;}))
      (mkIf cfg.genericSystem.enable (import ./config_system_generic.nix {inherit config lib pkgs;}))
      (mkIf cfg.kiosk.enable (import ./config_kiosk.nix {inherit config lib pkgs;}))
      (mkIf cfg.xfce.enable (import ./config_xfce.nix {inherit config lib pkgs;}))
    ];
}
