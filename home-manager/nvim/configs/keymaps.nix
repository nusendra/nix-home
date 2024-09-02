{
    neovimKeymaps = {
        customKeybindings = ''
            nnoremap <C-H> <C-W><C-H>
            nnoremap <C-J> <C-W><C-J>
            nnoremap <C-K> <C-W><C-K>
            nnoremap <C-L> <C-W><C-L>
            nnoremap <C-B> :Neotree toggle<CR>
            nnoremap <C-N> :tabnew<CR>
            nnoremap <C-Y> :tabprevious<CR>
            nnoremap <C-U> :tabnext<CR>
            nnoremap <C-F> :FixWhitespace<CR>
            nnoremap <C-P> :Telescope find_files<CR>
            nnoremap <C-O> :Telescope live_grep<CR>
            nnoremap <C-E> :lua vim.diagnostic.open_float()<CR>
            nnoremap <C-E> :lua vim.diagnostic.open_float()<CR>

            nmap s <Plug>(leap-forward-to)
            nmap S <Plug>(leap-backward-to)
        '';
    };
}
