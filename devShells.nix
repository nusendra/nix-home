{ pkgs, ... }:
{
  # nix develop ".#devShells.node18"
  node20 = pkgs.mkShell {
    description = "Node.js 18";
    buildInputs = with pkgs; [
      nodejs_20
      (nodePackages.yarn.override { nodejs = nodejs_20; })
    ];
  };
}
