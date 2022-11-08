{
  description = "Configuration";

  # To easily generate a derivation per architecture
  inputs.flake-utils.url = "github:numtide/flake-utils";
  # The web server
  inputs.cwi-foosball-web.url = "github:cwi-foosball/foosball-web";
  
  outputs = { self, nixpkgs, flake-utils, cwi-foosball-web }@attrs: {
    # We create a new module that can be used in existing NixOs systems.
    nixosModules.cwi-foosball-kiosk = {...}: {
      imports = [ ./foosballKiosk.nix ];
    };
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
      ## This is a function to create 3 configurations:
      mkNixosConfigAndIntegratedVm = import ./mkNixosConfigAndIntegratedVm.nix { inherit nixpkgs system pkgs; };
    in
      # Can't use // to merge as it does not recursively merge stuff like a.b = … and a.c = …
      # recursiveUpdate only works on 2 items so let's make it work on lists:
      lib.foldl lib.recursiveUpdate {} [
        ## This is the main configuration for the computer in the foosball room (nixos)
        ## Install it with:
        ## $ sudo nixos-rebuild switch --flake .#foosballrasp
        ## and test it on your laptop (it starts a qemu VM) with:
        ## $ nix build .#foosballrasp-vm
        ## $ ./result/bin/run-nixos-vm
        ## It has no server, and uses https://foosball.cwi.nl
        (mkNixosConfigAndIntegratedVm {
          name = "foosballrasp";
          myModules = [
            ./hardware-configuration.nix
            self.nixosModules.cwi-foosball-kiosk
            cwi-foosball-web.nixosModule.default
            {
              # Enable the "kiosk" (chromium stuff)
              services.CWIFoosballKiosk = {
                enableEverything = true;
                kiosk.urlServer = "https://foosball.cwi.nl";
              };
            }
          ];
        })
        ## This is the main configuration for the computer in the foosball room (nixos)
        ## Install it with:
        ## $ sudo nixos-rebuild switch --flake .#foosballrasp-extern-api-
        ## and test it on your laptop (it starts a qemu VM) with:
        ## $ nix build .#foosballrasp-extern-api-vm
        ## $ ./result/bin/run-nixos-vm
        ## It has a server, but uses the external api at https://foosball.cwi.nl
        (mkNixosConfigAndIntegratedVm {
          name = "foosballrasp-extern-api";
          myModules = [
            ./hardware-configuration.nix
            self.nixosModules.cwi-foosball-kiosk
            cwi-foosball-web.nixosModule.default
            {
              # Enable the "kiosk" (chromium stuff)
              services.CWIFoosballKiosk = {
                enableEverything = true;
                kiosk.urlServer = "localhost";
              };
              # Enable a local web server using the web server of foosball.cwi.nl
              # (can't get access to foosball.cwi.nl)
              services.CWIFoosballWeb = {
                enable = true;
                domainAPI = "https://foosball.cwi.nl";
              };
            }
          ];
        })
        ## This configuration is like the above one except that the full server (database/api/frontend…) is
        ## installed locally.
        ## Install it with:
        ## $ sudo nixos-rebuild switch --flake .#foosballrasp-with-api
        ## and test it on your laptop (it starts a qemu VM) with:
        ## $ nix build .#foosballrasp-with-api-vm
        ## $ ./result/bin/run-nixos-vm
        (mkNixosConfigAndIntegratedVm {
          name = "foosballrasp-with-api";
          myModules = [
            ./hardware-configuration.nix
            self.nixosModules.cwi-foosball-kiosk
            cwi-foosball-web.nixosModule.default
            {
              # Enable the "kiosk" (chromium stuff)
              services.CWIFoosballKiosk = {
                enableEverything = true;
                kiosk.urlServer = "localhost";
              };
              # Enable a local web server with the database and everything
              services.CWIFoosball = {
                enable = true;
              };
            }
          ];
        })
        ## This minimalist image may be useful in case you are lacking space to install a new system
        ## (remember that when you install a new system the new system is copied/compiled and then replaces the
        ## current one… so if all dependencies are different it may take twice the required space).
        ## Also remember that nix keeps old systems, in case you want to switch back to a previous version
        ## (for instance if the system does not boot anymore you can boot to a previous generation and rollback).
        ## For this reason you need to remember to remove (garbage collect) old generations, with, e.g.:
        ## $ sudo nix-collect-garbage -d
        ## The below configuration provides a minimalist system with no graphical interface to save space:
        ## 1. first you switch to this minimalist system:
        ## $ sudo nixos-rebuild switch --flake .#minimalist
        ## (make sure that it still boots, especially if you change the kernel)
        ## 2. Then you garbage collect the store:
        ## $ nix-collect-garbage -d
        ## 3. Finally you install the new system.
        ## If you want you can also install this emergency system in a different profile to always have a usable
        ## boot entry
        (mkNixosConfigAndIntegratedVm {
          name = "minimalist";
          myModules = [
            self.nixosModules.cwi-foosball-kiosk
            {
              services.CWIFoosballKiosk = {
                rasp3b.enable = true;
                login.enable = true;
                genericSystem.enable = true;
              };
            }
          ];
        })
      ]
  );
}
