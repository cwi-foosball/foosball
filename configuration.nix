{ config, pkgs, lib, ... }:
# Would be cleaner to do that part with flake… but flake seems to be more ram consuming than legacy nix for now (some work are being done on that right now)
let
  cwiFoosballWeb = builtins.fetchTarball {
    url = https://github.com/cwi-foosball/foosball-web/archive/1008b34e3efe9abac80308f4ac21b22bc5fe2cf8.tar.gz;
    # when you change the hash in url, write sha256 = ""; here, compile, and replace the hash with the hash
    # given in the error
    sha256 = "sha256:0lnh2yjq7ba4q3fafiqhfyifkv3wqlph4g9ralndx2373xnmhrqg";
  };
in
{  
  imports = [
    ./hardware-configuration.nix
    ./foosballKiosk.nix
    (cwiFoosballWeb + "/foosballModule.nix")
  ];
  # Enable the "kiosk" (chromium stuff)
  services.CWIFoosballKiosk = {
    enableEverything = true;
    kiosk.urlServer = "https://foosball.cwi.nl";
  };
}
