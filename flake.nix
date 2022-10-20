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

        packages.nixosConfigurations.foosballrasp = nixpkgs.lib.nixosSystem {
          system = system; # flake needs to know the architecture of the OS
          
          modules = [
            ./config_rasp_3B.nix
            ./config_login_rasp.nix
            ./config_system_generic.nix
            ./config_system_x11.nix
          ];
        };
      });
}
