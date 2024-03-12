thanks to https://github.com/Misterio77/nix-starter-configs/blob/main/README.md

## Commands

```
nix --version
export NIX_CONFIG="experimental-features = nix-command flakes"
home-manager switch --flake .#nusendra@macbook-pro-m2

```

By default I addded Hello program to home manger, so that you can test by run this command `hello` into your terminal. Eventhough you haven't hello program
in your machine, you can run this hello from nix's home-manager
