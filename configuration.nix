{ config, pkgs, lib, isRunWithoutFlake ? true , ... }:
# Would be cleaner to do that part with flake… but flake seems to be more ram consuming than legacy nix for now (some work are being done on that right now)
let
  cwiFoosballWeb = builtins.fetchTarball {
    url = https://github.com/cwi-foosball/foosball-web/archive/1feb016da0be6362c42cf067fa03b1f5f2062985.tar.gz;
    # when you change the hash in url, write sha256 = ""; here, compile, and replace the hash with the hash
    # given in the error
    sha256 = "bhiwXgExax0rFFXyibqhEC/H8uK6lbEVWYDpBbfx89A=";
  };
in
{  
  imports = [
    ./modules/foosballKiosk.nix              # Custom module created for the kiosk (chromium stuff)
    (cwiFoosballWeb + "/foosballModule.nix") # External module (imported just above) to setup the web server
  ] ++ lib.optional isRunWithoutFlake [      # Not compatible with SD cards… So we use specialArgs to disable it
    ./hardware-configuration.nix             # Hardware
    {
      # Useful to ensure that nix-shell use the same version as the system (or it might download too much stuff)
      # In flake we don't use <nixpkgs> since it's part of the flake's input. Without flake
      # the script switch.sh provides a pinned version of nixpkgs
      nix.nixPath = [ "nixpkgs=${<nixpkgs>}" ];
    }
  ];
  # Enable the "kiosk" (chromium stuff)
  services.CWIFoosballKiosk = {
    enableEverything = true;
    kiosk.urlServer = "localhost"; # The website is running locally
  };
  # Enable a local web server using the web server of foosball.cwi.nl for api/database
  # (can't get access to foosball.cwi.nl)
  services.CWIFoosballWeb = {
    enable = true;
    domainAPI = "https://foosball.cwi.nl";
  };
}
