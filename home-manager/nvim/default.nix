{ pkgs, ... }:
{
    programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        plugins = with pkgs.vimPlugins; [
            nvim-surround
            {
                plugin = lualine-nvim;
                type = "lua";
                config = builtins.readFile(./configs/lua-line.lua);
            }
        ];
    };
}