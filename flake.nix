{
  description = "Nusendra nix home config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "aarch64-darwin";
  in {
    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "nusendra@macbook-pro-m2" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        # > Our main home-manager configuration file <
        modules = [
          ./home-manager/home.nix
        ];
      };
    };

    devShells = import ./devShells.nix {
      pkgs = nixpkgs.legacyPackages.${system};
    };
  };
}
