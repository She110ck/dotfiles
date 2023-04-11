"source $VIMRUNTIME/defaults.vim   " Do not wipe default pre-configs.

set smarttab
set tabstop=2
set shiftwidth=2
" set softtabstop=2
set autoindent
set smartindent
set hlsearch
set incsearch
set nu
set paste
set expandtab
set mouse=
set ttymouse=
set showcmd
set so=999

set laststatus=2
set statusline=%t       "tail of the filename
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%h      "help file flag
set statusline+=\ %2#error#%m%*      "modified flag
set statusline+=%#DiffAdd#%r%*      "read only flag
set statusline+=%=      "left/right separator
set statusline+=%y      "filetype
set statusline+=%2c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
hi statusline ctermfg=DarkBlue ctermbg=White
hi StatusLineNC ctermfg=Black ctermbg=DarkGray
hi VertSplit ctermfg=Blue ctermbg=DarkBlue

highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red

" this commands works not correct enough on windows10 terminal. 
set cursorline
hi clear CursorLine
hi CursorLine gui=underline cterm=underline

au InsertEnter * set nocul
au InsertLeave * set cul


command! WipeReg for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor

let mapleader=','
let g:mapleader=','
nnoremap <F3> :noh <CR>
nnoremap <F4> :set invnumber <CR>

if &diff
    map <leader>1 :diffget LOCAL<CR>
    map <leader>2 :diffget BASE<CR>
    map <leader>3 :diffget REMOTE<CR>
endif


