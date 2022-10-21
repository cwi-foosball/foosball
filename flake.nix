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

        # With binfmt configured on the host you can compile an sd image like that:
        # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
        # nix build .#packages.aarch64-linux.nixosConfigurations.nogui.config.system.build.sdImage
        packages.nixosConfigurations.nogui = nixpkgs.lib.nixosSystem {
          system = system; # flake needs to know the architecture of the OS
          modules = [
            ({modulesPath, ...}: {    imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ]; })
            ./config_rasp_3B.nix
            ./config_login_rasp.nix
            ./config_system_generic.nix
          ];
        };

        
        packages.nixosConfigurations.foosballrasp = nixpkgs.lib.nixosSystem {
          system = system; # flake needs to know the architecture of the OS
          
          modules = [
            ./hardware-configuration.nix
            ./config_rasp_3B.nix
            ./config_login_rasp.nix
            ./config_system_generic.nix
            ./config_system_x11.nix
          ];
        };
      });
}
