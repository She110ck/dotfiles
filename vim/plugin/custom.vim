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
set expandtab
" mouse interaction handles differently
if empty($TMUX)
  set mouse=
  set ttymouse=
else
  set mouse=a
  set ttymouse=xterm2
endif

set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

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

let g:colors_name = ''
let g:colors = getcompletion('', 'color')
func! NextColors()
    let idx = index(g:colors, g:colors_name)
    return (idx + 1 >= len(g:colors) ? g:colors[0] : g:colors[idx + 1])
endfunc

let mapleader=','
let g:mapleader=','
nnoremap <F3> :noh <CR>
nnoremap <F4> :set invnumber <CR>:set invpaste paste? <CR>
nnoremap <F5> :execute "colo " .. NextColors()<CR>
":highlight Normal ctermbg=none<CR>

if &diff
    map <leader>1 :diffget LOCAL<CR>
    map <leader>2 :diffget BASE<CR>
    map <leader>3 :diffget REMOTE<CR>
endif

" visual difference between envs
if hostname() =~ "dev"
  colorscheme desert
endif

if hostname() =~ "test"
  colorscheme pablo
endif

if hostname() =~ "stage"
  colorscheme zellner
endif

if hostname() =~ "prod"
  colorscheme murphy
endif

imap ,so System.out.println();<left><left>

