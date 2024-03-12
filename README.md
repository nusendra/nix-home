thanks to https://github.com/Misterio77/nix-starter-configs/blob/main/README.md

## Commands

```
nix --version
export NIX_CONFIG="experimental-features = nix-command flakes"
home-manager switch --flake .#nusendra@macbook-pro-m2

```

By default, I've included the 'Hello' program in Home Manager, allowing you to test it by simply running the command hello in your terminal. Even if the 'Hello' program isn't installed on your machine, you can still access it through Nix's Home Manager.
