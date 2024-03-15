{ pkgs, ... }:
let
    nvimKeymaps = import ./configs/keymaps.nix;
    nvimSettings= import ./configs/settings.nix;

    customKeybindings = ''
        ${nvimKeymaps.neovimKeymaps.customKeybindings}
        ${nvimSettings.neovimSettings.customSettings}
    '';
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
            plenary-nvim
            nvim-web-devicons
            nui-nvim
            neo-tree-nvim
            telescope-nvim
            {
                plugin = lualine-nvim;
                type = "lua";
                config = builtins.readFile(./configs/lua-line.lua);
            }
        ];
        extraConfig = customKeybindings;
    };
}
