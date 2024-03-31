{
  description = "Nusendra nix home config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    nix-colors.url = "github:misterio77/nix-colors";

  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    ...
  }:
  # @ inputs:
  flake-utils.lib.eachDefaultSystem (system:
    {
      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      packages = {
        homeConfigurations = {
          "default" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance
            # extraSpecialArgs = {inherit inputs outputs;};
            # > Our main home-manager configuration file <
            modules = [
              ./home-manager/home.nix
            ];
          };
        };
      };

      devShells = import ./devShells.nix {
        pkgs = nixpkgs.legacyPackages.${system};
      };
    }
  );
}
