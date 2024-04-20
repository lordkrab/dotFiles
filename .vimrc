" Fuzzy find
set rtp+=/usr/local/opt/fzf

syntax on
set number
set relativenumber
set backspace=indent,eol,start
inoremap jh <Esc>
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz
nnoremap n nzz
nnoremap N Nzz
set ignorecase
set smartcase

" Enable searching as you type, rather than waiting till you press enter.
set incsearch
