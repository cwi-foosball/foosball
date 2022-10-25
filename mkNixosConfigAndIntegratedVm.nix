{ nixpkgs, system, pkgs, ... }:
{ name, myModules ? [], myModulesNotVm ? [], myModulesInVm ? [], nixosConfig ? {} }:
{
  # Main system
  packages.nixosConfigurations.${name} = nixpkgs.lib.nixosSystem {
    system = system; # flake needs to know the architecture of the OS
    # specialArgs = attrs; # One module needs access to nixpkgs to import qemu stuff (actually maybe not even necessary)
    modules = myModules ++ myModulesNotVm ++ [ nixosConfig ];
  };
  # Qemu with host integration (for better efficiency, copy/paste…)
  # (also easier to toogle on/off)
  packages."${name}-vm" =
    let
      nixosConfigWithVM = nixpkgs.lib.nixosSystem {
        system = system; # flake needs to know the architecture of the OS
        # specialArgs = attrs; # One module needs access to nixpkgs to import qemu stuff (actually maybe not even necessary)
        modules = myModules ++ myModulesInVm ++ [
          "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" # Not compatible with non-vm machines
          nixosConfig
        ];
      };
    in pkgs.writeShellApplication {
      name = "run-nixos-vm";
      runtimeInputs = [ pkgs.virt-viewer ];
      text = ''
                ${nixosConfigWithVM.config.system.build.vm}/bin/run-nixos-vm & PID_QEMU="$!"
                sleep 1 # I think some tools have an option to wait like -w
                remote-viewer spice://127.0.0.1:5930
                kill "$PID_QEMU"
              '';
    };
  ## NOT TESTED
  ## You can even directly create an SD image to burn on the card with dd.
  ## Most likely (unless your system is aarch64) you need binfmt configured on the host to
  ## emulate aarch64 (may be a bit slower than native build)
  ## In nixos (configuration.nix):
  ##  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  ## Then, you can compile an sd image like that:
  ## $ nix build .#packages.aarch64-linux.nixosConfigurations.NAMEOFIMAGE-sdcard.config.system.build.sdImage
  # Main system
  packages.nixosConfigurations."${name}-sdcard" = nixpkgs.lib.nixosSystem {
    system = system; # flake needs to know the architecture of the OS
    modules = myModules ++ myModulesNotVm ++ [
      ({modulesPath, ...}: { imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")]; })
      nixosConfig
    ];
  };
}
