{
    neovimKeymaps = {
        customKeybindings = ''
            nnoremap <C-H> <C-W><C-H>
            nnoremap <C-J> <C-W><C-J>
            nnoremap <C-K> <C-W><C-K>
            nnoremap <C-L> <C-W><C-L>
            nnoremap <C-B> :NeoTreeFocusToggle<CR>
            nnoremap <C-N> :tabnew<CR>
            nnoremap <C-Y> :tabprevious<CR>
            nnoremap <C-U> :tabnext<CR>
            nnoremap <C-F> :FixWhitespace<CR>
            nnoremap <C-P> :Telescope find_files<CR>
            nnoremap <C-O> :Telescope live_grep<CR>
        '';
    };
}
