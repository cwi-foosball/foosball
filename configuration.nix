{ config, pkgs, lib, ... }:
# Would be cleaner to do that part with flake… but flake seems to be more ram consuming than legacy nix for now (some work are being done on that right now)
let
  cwiFoosballWeb = builtins.fetchTarball {
    url = https://github.com/cwi-foosball/foosball-web/archive/fef12114c9ef0cf67bc7e367ff3f7f4166455f78.tar.gz;
    # when you change the hash in url, write sha256 = ""; here, compile, and replace the hash with the hash
    # given in the error
    sha256 = "sha256:06bjp2472ylhnl4g77dr2mzknq9vp9srv2iym2f0fhxgkxg7ygzb";
  };
in
{  
  imports = [
    ./hardware-configuration.nix             # Hardware
    ./modules/foosballKiosk.nix              # Custom module created for the kiosk (chromium stuff)
    (cwiFoosballWeb + "/foosballModule.nix") # External module (imported just above) to setup the web server
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
