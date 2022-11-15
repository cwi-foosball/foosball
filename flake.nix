{
  description = "Configuration";

  # nixpkgs follow unstable to get latest kernel
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  # To easily generate a derivation per architecture
  inputs.flake-utils.url = "github:numtide/flake-utils";
  # The web server
  inputs.cwi-foosball-web.url = "github:cwi-foosball/foosball-web";
  
  outputs = { self, nixpkgs, flake-utils, cwi-foosball-web }@attrs: {
    # We create a new module that can be used in existing NixOs systems.
    nixosModules.cwi-foosball-kiosk = {...}: {
      imports = [ ./modules/foosballKiosk.nix ];
    };
    # build using nix build .#nixosConfigurations.lxqtSdcard.config.system.build.sdImage
    nixosConfigurations.lxqtSdcard = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ({modulesPath, ...}: {
          imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")];
          # Do not compress the image as we want to use it straight away
          sdImage.compressImage = false;
        })
        ({ pkgs, lib, ... }: {
          boot.kernelPackages = pkgs.linuxPackages_latest;
          # remove zfs
          boot.supportedFilesystems = with lib; mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
          boot.kernelParams = [ "cma=512M" ];
          # Enable the X11 windowing system.
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

          # XKB's configuration also applies in the console
          console.useXkbConfig = true;

          services.xserver.libinput = {
            enable = true;
          };
          system.stateVersion = "22.11";
          environment.systemPackages = with pkgs; [ chromium ];
          users.users.pi = {
            isNormalUser = true;
            # In theory one should use hashedPassword but who care, the password is public anyway
            password = "cwifoosball";
            extraGroups = [ "wheel" "audio"  ]; # Enable ‘sudo’ for the user.
            # For ssh access
            openssh.authorizedKeys.keys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDjQGQzn3+PxNGMdcw+uwFUMaQpqExnM2mkL3lyAjvc3ytyNfWIIVHqOh/s5PcPmjtGvUHtrPHi+6uFa0zIWJL2DLAGJ7t3Cy1yCStJsGyquxe1Th2X1h02mEL+yDKxfSYC8AWWpG/WoiwkIHhiMsmP5tNGtRikBZp8I0GxvNLbC0UpLZ5jHxrvxu6sKCxHerMt96wwJng7NI/YwfdZd8Z/fuCOYwqIgf/d0El0nMZjYCtn0b5s87c3EI6+ViYm0z9XyD5tLiXJleF8odTS6YkrFZpgkO4yoqPJPkuudMDuozx2iFVcamR1B8YLNOVLV/BupnoMULN80y+EyAa1x5hO0QLr22lk6zoCWmkfDz5lhvriyW5mLxD1TTo94aabhS8tGMoR1f1kuy5/GtT/rn0GO03fcTjRQP2c/uQeYwCwPTPQBwlVwidwAtd2Re8FWk0uYqKkvgV6GTit1AwYBiqQStZrzcbyov4vHzhOaNpcgslnF1Xmk7R2FMsH7zxEeBk= leo@bestos"
            ];
          };
          users.users.root = {
            # For ssh access
            openssh.authorizedKeys.keys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDjQGQzn3+PxNGMdcw+uwFUMaQpqExnM2mkL3lyAjvc3ytyNfWIIVHqOh/s5PcPmjtGvUHtrPHi+6uFa0zIWJL2DLAGJ7t3Cy1yCStJsGyquxe1Th2X1h02mEL+yDKxfSYC8AWWpG/WoiwkIHhiMsmP5tNGtRikBZp8I0GxvNLbC0UpLZ5jHxrvxu6sKCxHerMt96wwJng7NI/YwfdZd8Z/fuCOYwqIgf/d0El0nMZjYCtn0b5s87c3EI6+ViYm0z9XyD5tLiXJleF8odTS6YkrFZpgkO4yoqPJPkuudMDuozx2iFVcamR1B8YLNOVLV/BupnoMULN80y+EyAa1x5hO0QLr22lk6zoCWmkfDz5lhvriyW5mLxD1TTo94aabhS8tGMoR1f1kuy5/GtT/rn0GO03fcTjRQP2c/uQeYwCwPTPQBwlVwidwAtd2Re8FWk0uYqKkvgV6GTit1AwYBiqQStZrzcbyov4vHzhOaNpcgslnF1Xmk7R2FMsH7zxEeBk= leo@bestos"
            ];
          };
          # Enable the OpenSSH server.
          services.openssh = {
            enable = true;
            # Forbid password authentication (too much risks with a trivial password), use keys instead
            passwordAuthentication = false;
          };
        })
      ];
    };
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
      ## This is a function to create 3 configurations:
      mkNixosConfigAndIntegratedVm = import ./lib/mkNixosConfigAndIntegratedVm.nix { inherit nixpkgs system pkgs; };
    in
      # Can't use // to merge as it does not recursively merge stuff like a.b = … and a.c = …
      # recursiveUpdate only works on 2 items so let's make it work on lists:
      lib.foldl lib.recursiveUpdate {} [
        ## This is the main configuration for the computer in the foosball room (nixos)
        ## Install it with:
        ## $ sudo nixos-rebuild switch --flake .#foosballrasp
        ## or without flake it seems to compile much faster on the rasp `sudo nixos-rebuild switch`
        ## and test it on your laptop (it starts a qemu VM) with:
        ## $ nix build .#foosballrasp-vm
        ## $ ./result/bin/run-nixos-vm
        ## It has no server, and uses https://foosball.cwi.nl
        (mkNixosConfigAndIntegratedVm {
          name = "foosballrasp";
          myModules = [
            ./configuration.nix
          ];
          mySpecialArgs = {
            # We include hardware config in configuration.nix to allow non-flake setup, but we need to disable
            # it for SD cards
            includeHardwareConfig = false;
          };
        })
        ## Install it with:
        ## $ sudo nixos-rebuild switch --flake .#foosballrasp
        ## and test it on your laptop (it starts a qemu VM) with:
        ## $ nix build .#foosballrasp-vm
        ## $ ./result/bin/run-nixos-vm
        ## It has no server, and uses https://foosball.cwi.nl
        (mkNixosConfigAndIntegratedVm {
          name = "foosballrasp-no-server";
          myModulesSystemOnly = [
            ./hardware-configuration.nix
          ];
          myModules = [
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
        ## Install it with:
        ## $ sudo nixos-rebuild switch --flake .#foosballrasp-extern-api-
        ## and test it on your laptop (it starts a qemu VM) with:
        ## $ nix build .#foosballrasp-extern-api-vm
        ## $ ./result/bin/run-nixos-vm
        ## It has a server, but uses the external api at https://foosball.cwi.nl
        (mkNixosConfigAndIntegratedVm {
          name = "foosballrasp-extern-api";
          myModulesSystemOnly = [
            ./hardware-configuration.nix
          ];
          myModules = [
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
          myModulesSystemOnly = [
            ./hardware-configuration.nix
          ];
          myModules = [
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
          myModulesSystemOnly = [
            ./hardware-configuration.nix
          ];
          myModules = [
            self.nixosModules.cwi-foosball-kiosk
            {
              services.CWIFoosballKiosk = {
                rasp3b.enable = true;
                login.enable = true;
                genericSystem = {
                  enable = true;
                  # noGui = true;
                };
              };
            }
          ];
        })
      ]
  );
}
