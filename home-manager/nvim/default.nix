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
            {
                plugin = telescope-nvim;
                type = "lua";
                config = builtins.readFile(./configs/telescope-nvim.lua);
            }
            {
                plugin = neo-tree-nvim;
                type = "lua";
                config = builtins.readFile(./configs/neo-tree.lua);
            }
            {
                plugin = lualine-nvim;
                type = "lua";
                config = builtins.readFile(./configs/lua-line.lua);
            }
            {
                plugin = neogit;
                type = "lua";
                config = builtins.readFile(./configs/neogit.lua);
            }

            #LSP and completion
            # nvim-lspconfig
            # cmp-nvim-lsp
            cmp-buffer
            cmp-path
            cmp-cmdline
            lsp-zero-nvim
            cmp-nvim-lsp
            {
                plugin = nvim-cmp;
                type = "lua";
                config = builtins.readFile(./configs/cmp.lua);
            }
            {
                plugin = lazy-lsp-nvim;
                type = "lua";
                config = builtins.readFile(./configs/lazy-lsp.lua);
            }

            # Pretty errors
            trouble-nvim

            # jump to the specific word easily
            leap-nvim

            # copilot
            {
                plugin = copilot-lua;
                type = "lua";
                config = builtins.readFile(./configs/copilot.lua);
            }
        ];
        extraConfig = customKeybindings;
    };
}
