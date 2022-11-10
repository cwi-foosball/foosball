{ nixpkgs, system, pkgs, ... }:
{ name,
  myModules ? [],
  myModulesNotVm ? [],
  myModulesInVm ? [],
  defaultConfig ? {} }:
{
  # Main system
  # You can even compile it on a laptop with:
  # $ nix build .#packages.aarch64-linux.nixosConfigurations.foosballrasp-extern-api.config.system.build.toplevel
  # Or compile and deploy via ssh using something like:
  # $ nixos-rebuild switch .#packages.aarch64-linux.nixosConfigurations.foosballrasp-extern-api --target-host root@10.42.0.169
  # edit: seems it's not working. I found how to copy it using:
  # outputDerivation=$(nix build .#packages.aarch64-linux.nixosConfigurations.minimalist.config.system.build.toplevel --json | jq -r '.[0].outputs.out')
  # nix copy --to ssh://root@10.42.0.169 "$outputDerivation"
  # ssh root@10.42.0.169 "nix-env -p /nix/var/nix/profiles/system --set $outputDerivation"
  # ssh root@10.42.0.169 "$outputDerivation/bin/switch-to-configuration switch"
  # ssh root@10.42.0.169 "reboot"
  packages.nixosConfigurations.${name} = nixpkgs.lib.nixosSystem {
    system = system; # flake needs to know the architecture of the OS
    # specialArgs = attrs; # One module needs access to nixpkgs to import qemu stuff (actually maybe not even necessary)
    modules = myModules ++ myModulesNotVm ++ [ defaultConfig ];
  };
  # Qemu with host integration (for better efficiency, copy/paste…)
  # (also easier to toogle on/off)
  packages."${name}-vm" =
    let
      nixosConfigWithVM = nixpkgs.lib.nixosSystem {
        system = system; # flake needs to know the architecture of the OS
        modules = myModules ++ myModulesInVm ++ [
          "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" # Not compatible with non-vm machines
          defaultConfig
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
      ({lib, modulesPath, ...}: {
        imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")];
        # otherwise it tries to install zfs which is broken on recent pi
        boot.supportedFilesystems = lib.mkForce [ ];
        # Do not compress the image as we want to use it straight away
        sdImage.compressImage = false;
      })
      defaultConfig
    ];
  };
}
