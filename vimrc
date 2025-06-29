""""""""""""""""""""""""""""""""""""""""""""""""""
" +------------------+
" |Rohan's Vim Config|
" +------------------+
"
" Maintainer: Rohan Shenoy - @222rohan
" (Config adapted from vimrc by @axim)
"
" Sections: 
"   - Features 
"   - Editing
"   - Appearance
"   - Custom Shortcuts
"   - Misc
"
" TODO:
"   - Toggle brackets around word(s)
"
""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""
" Features:
"
" Turn backup off
set nobackup
set nowb
set noswapfile

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Always show current position
set ruler

" Sets how many lines of history VIM has to remember
set history=222

" Turn on the Wild menu
set wildmenu
" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" Enable filetype plugins
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread
au FocusGained,BufEnter * silent! checktime
" Don't redraw while executing macros (good performance config)
set lazyredraw
" A buffer becomes hidden when it is abandoned
set hidden

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Configure Search 
set ignorecase
set smartcase
set hlsearch
set incsearch
" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

let s:comment_map = { 
    \   "c": '\/\/',
    \   "cpp": '\/\/',
    \   "go": '\/\/',
    \   "java": '\/\/',
    \   "javascript": '\/\/',
    \   "lua": '--',
    \   "scala": '\/\/',
    \   "php": '\/\/',
    \   "python": '#',
    \   "ruby": '#',
    \   "rust": '\/\/',
    \   "sh": '#',
    \   "desktop": '#',
    \   "fstab": '#',
    \   "conf": '#',
    \   "profile": '#',
    \   "bashrc": '#',
    \   "bash_profile": '#',
    \   "mail": '>',
    \   "eml": '>',
    \   "bat": 'REM',
    \   "ahk": ';',
    \   "vim": '"',
    \   "tex": '%',
    \ }

""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""
" Editing: 
"
" Line Numbering
set relativenumber
set number

" Configure Tabs
set expandtab
set shiftwidth=4
set tabstop=4

" Wrapping 
set lbr
set tw=500
set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

" Map 0 to first non blank character
map 0 ^

""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""
" Appearance:
"
" Enable syntax highlighting
syntax enable

" Set regular expression engine automatically
set regexpengine=0

" Enable 256 colors palette in Gnome Terminal
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

" set the theme
try
    colorscheme desert
catch
endtry

set background=dark

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Make ruler pretty
set rulerformat=%39(%#Tabline#\ %t\ %m\ %8(%l:%c%V%)\ (%L\ Lines)\ %4p%%%)

" Line number colours
highlight LineNr ctermbg=Black ctermfg=DarkGrey guifg=#808080 cterm=NONE gui=NONE
highlight ModeMsg term=underline ctermfg=236 ctermbg=144 guifg=#333333 guibg=#c2bfa5 
set cursorline
set cursorlineopt=number

""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""
" Shortcuts:
"
" Set leader key to ,
let mapleader = ","
" Change command mode key from : to ;  
map ; :
"
"
" Visual mode pressing * or # searches for the current selection
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Buffers and Windows
map <leader>b :ls<cr>
map <leader>l :bnext<cr>
map <leader>k :bprevious<cr>
map <leader>n :enew<cr>
map <leader>v :vnew<cr>
map <leader>d :bd<cr>
map <leader>qd :bd!<cr>
map <leader>w <C-w>w

" Toggle Comments
nnoremap <leader>/ :call ToggleComment()<cr>
vnoremap <leader>/ :call ToggleComment()<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc (Functions):
"
function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

" Delete trailing white space on save, useful for some filetypes ;)
function! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun
if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
endif

function! ToggleComment()
    if has_key(s:comment_map, &filetype)
        let comment_leader = s:comment_map[&filetype]
        if getline('.') =~ "^\\s*" . comment_leader . " " 
            " Uncomment the line
            execute "silent s/^\\(\\s*\\)" . comment_leader . " /\\1/"
        else 
            if getline('.') =~ "^\\s*" . comment_leader
                " Uncomment the line
                execute "silent s/^\\(\\s*\\)" . comment_leader . "/\\1/"
            else
                " Comment the line
                execute "silent s/^\\(\\s*\\)/\\1" . comment_leader . " /"
            end
        end
    else
        echo "No comment leader found for filetype"
    end
endfunction


