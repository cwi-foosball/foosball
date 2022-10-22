{
  description = "Configuration";

  # To easily generate a derivation per architecture
  inputs.flake-utils.url = "github:numtide/flake-utils";
  
  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      {

        packages.hello = pkgs.hello;
        packages.default = pkgs.hello;

        packages.foosballrasp-with-vm-integration = pkgs.writeShellApplication {
          name = "run-nixos-vm";
          runtimeInputs = [ pkgs.virt-viewer ];
          text = ''
            ${self.packages.${system}.nixosConfigurations.foosballrasp.config.system.build.vm}/bin/run-nixos-vm &
            sleep 1 # I think some tools have an option to wait like -w
            remote-viewer spice://127.0.0.1:5930
            kill $PID_QEMU
          '';
        };
        
        packages.nixosConfigurations = {
          ## This is the main configuration for the computer in the foosball room (nixos)
          ## Install it with:
          ## $ sudo nixos-rebuild switch --flake .#foosballrasp
          ## and test it on your laptop (it starts a qemu VM) with:
          ## $ sudo nixos-rebuild build-vm --flake .#foosballrasp
          ## $ ./result/bin/run-nixos-vm
          foosballrasp = nixpkgs.lib.nixosSystem {
            system = system; # flake needs to know the architecture of the OS
            
            modules = [
              # "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
              ./hardware-configuration.nix
              ./config_rasp_3B.nix
              ./config_login_rasp.nix
              ./config_system_generic.nix
              ./config_system_x11.nix
              ./config_xfce.nix
            ] + nixpkgs.lib.optional (config ? virtualisation.qemu) "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix";
          };
        
          ## This may be useful in case you are lacking space to install a new system
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
          minimalist = nixpkgs.lib.nixosSystem {
            system = system; # flake needs to know the architecture of the OS
            modules = [
              ({modulesPath, ...}: {    imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ]; })
              ./config_rasp_3B.nix
              ./config_login_rasp.nix
              ./config_system_generic.nix
            ];
          };

          ## Like minimalist but to create an SD card.
          ## With binfmt configured on the host:
          ## $ boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
          ## you can compile an sd image like that:
          ## $ nix build .#packages.aarch64-linux.nixosConfigurations.minimalistSdcard.config.system.build.sdImage
          minimalistSdcard = nixpkgs.lib.nixosSystem {
            system = system; # flake needs to know the architecture of the OS
            modules = [
              ({modulesPath, ...}: {    imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ]; })
              ./config_rasp_3B.nix
              ./config_login_rasp.nix
              ./config_system_generic.nix
            ];
          };
          
        };
      });
}
