{ pkgs, ... }:
let
    nvimKeymaps = import ./configs/keymaps.nix;
in
{
    programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        plugins = with pkgs.vimPlugins; [
            vim-trailing-whitespace
            auto-pairs
            vim-fugitive
            comment-nvim
            oceanic-next
            {
                plugin = lualine-nvim;
                type = "lua";
                config = builtins.readFile(./configs/lua-line.lua);
            }
        ];
        extraConfig = nvimKeymaps.neovimKeymaps.customKeybindings;
    };
}