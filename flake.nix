{
  description = "Configuration";

  # To easily generate a derivation per architecture
  inputs.flake-utils.url = "github:numtide/flake-utils";
  
  outputs = { self, nixpkgs, flake-utils }@attrs: flake-utils.lib.eachDefaultSystem (system:
    let
      
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
      ## This is a function to create 3 configurations:
      mkNixosConfigAndIntegratedVm = import ./mkNixosConfigAndIntegratedVm.nix { inherit nixpkgs system pkgs; };
    in
      # Can't use // to merge as it does not recursively merge stuff like a.b = … and a.c = …
      # recursiveUpdate only works on 2 items so let's make it work on lists:
      lib.foldl lib.recursiveUpdate {} [
        {
          # You can install these modules individually if you want to integrate this to an existing NixOs install
          # Otherwise just use the functions we provide.
          nixosModules.hardware-configuration-rasp3b = ./hardware-configuration.nix;
          nixosModules.config_rasp_3B = ./config_rasp_3B.nix;
          nixosModules.config_login_rasp = ./config_login_rasp.nix;
          nixosModules.config_system_generic = ./config_system_generic.nix;
          nixosModules.config_system_x11 = ./config_system_x11.nix;
          nixosModules.config_xfce = ./config_xfce.nix;
        }
        ## This is the main configuration for the computer in the foosball room (nixos)
        ## Install it with:
        ## $ sudo nixos-rebuild switch --flake .#foosballrasp
        ## and test it on your laptop (it starts a qemu VM) with:
        ## $ sudo nixos-rebuild build-vm --flake .#foosballrasp
        ## $ ./result/bin/run-nixos-vm
        (mkNixosConfigAndIntegratedVm {
          name = "foosballrasp";
          myModules = [
            ./hardware-configuration.nix
            ./config_rasp_3B.nix
            ./config_login_rasp.nix
            ./config_system_generic.nix
            ./config_system_x11.nix
            ./config_xfce.nix
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
            ./config_rasp_3B.nix
            ./config_login_rasp.nix
            ./config_system_generic.nix
          ];
        })
      ]
  );
}
