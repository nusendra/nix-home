{
    neovimKeymaps = {
        customKeybindings = ''       
            set relativenumber
            set number
            set wrap
            set wrapmargin=8
            set linebreak
            set showbreak="↪"
            set autoindent
            set ttyfast

            " Theme & Colorscheme
            set termguicolors
            syntax enable
            colorscheme OceanicNext

            " Tab Control
            set smarttab
            set tabstop=2
            set softtabstop=2
            set shiftwidth=2
            set shiftround

            nnoremap <C-H> <C-W><C-H>
            nnoremap <C-J> <C-W><C-J>
            nnoremap <C-K> <C-W><C-K>
            nnoremap <C-L> <C-W><C-L>
            nnoremap <C-B> :NvimTreeToggle<CR>
            nnoremap <C-N> :tabnew<CR>
            nnoremap <C-Y> :tabprevious<CR>
            nnoremap <C-U> :tabnext<CR>
            nnoremap <C-F> :FixWhitespace<CR>
        '';
    };
}