{
  description = "Nusendra nix home config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # cmdman - Command Manager CLI
    cmdman.url = "github:nusendra/cmdman";

    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    cmdman,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "aarch64-darwin";
  in {
    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "nusendra" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs cmdman;};
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
