" Copyright 2023 Jacob Trimble
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"     http://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.

" Altered spf12 (https://github.com/spf13/spf13-vim)
" Help from (http://yannesposito.com/Scratch/en/blog/Vim-as-IDE/)

call plug#begin()

Plug 'altercation/vim-colors-solarized'
Plug 'bronson/vim-trailing-whitespace'
Plug 'bling/vim-airline'
Plug 'scrooloose/syntastic'
Plug 'Shougo/vimproc.vim', {'do': 'make'}
Plug 'Shougo/unite.vim'
Plug 'tpope/vim-obsession'
Plug 'rking/ag.vim'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

set nocompatible

filetype plugin indent on         " Automatically detect file types
syntax enable                     " Syntax highlighting
set mouse=a                       " Automatically enable mouse usage
set mousehide                     " Hide the mouse while typing
scriptencoding utf-8

set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows Compatibility
set virtualedit=onemore           " Allow for cursor beyond last character
set history=1000                  " Store a ton of history (default is 20)
set spell                         " Spell checking is on
set hidden                        " Allow buffer switching without saving
set iskeyword-=.                  " '.' is an end of word designator
set iskeyword-=#                  " '#' is an end of word designator
set iskeyword-=-                  " '-' is an end of word designator

set t_Co=256                      " Fake 256-color support since tmux is evil.
let g:solarized_termcolors=256
set background=dark
try
    colorscheme solarized
catch
endtry
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline_theme = 'solarized'

set showmode
set cursorline
highlight clear SignColumn        " SignColumn should match background
highlight SpellBad cterm=underline

set backspace=indent,eol,start    " Backspace for dummies
set linespace=0                   " No extra spaces between rows
set number                        " Line numbers on
set showmatch                     " Show matching brackets/parenthesis
set incsearch                     " Find as you type search
set hlsearch                      " Highlight search terms
set winminheight=0                " Windows can be 0 line high
set ignorecase                    " Case insensitive search
set smartcase                     " Case sensitive when uc present
set whichwrap=b,s,h,l,<,>,[,]     " Backspace and cursor keys wrap too
set scrolljump=5                  " Lines to scroll when cursor leaves screen
set scrolloff=3                   " Minimum lines to keep above and below cursor
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

set backup                        " Backups are nice ...
set backupdir=~/.vim/backup//     " Directory for backup files
set dir=~/.vim/swap//             " Directory for swap files
if has('persistent_undo')
    set undofile                  " So is persistent undo ...
    set undodir=~/.vim/undo//     " Directory for undo files
    set undolevels=1000           " Maximum number of changes that can be undone
    set undoreload=10000          " Maximum number lines to save for undo on a buffer reload
endif

set nowrap                      " Do not wrap long lines
set autoindent                  " Indent at the same level of the previous line
set shiftwidth=2                " Use indents of 2 spaces
set expandtab                   " Tabs are spaces, not tabs
set tabstop=2                   " An indentation every two columns
set softtabstop=2               " Let backspace delete indent
set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
set splitright                  " Puts new vsplit windows to the right of the current
set splitbelow                  " Puts new split windows to the bottom of the current
set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)

let g:syntastic_reuse_loc_lists = 0
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_python_checkers = ['pylint']
let g:syntastic_javascript_checkers = ['eslint']

" Remove trailing whitespaces and ^M chars
autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> :FixWhitespace
" Add more file extension highlighting.
autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
autocmd BufNewFile,BufRead *.coffee set filetype=coffee
autocmd BufNewFile,BufRead *.gyp set filetype=conf
autocmd BufNewFile,BufRead *.gypi set filetype=conf
autocmd BufNewFile,BufRead *.mm set filetype=objcpp
" For some reason this is set to 4 otherwise.
autocmd FileType python setlocal shiftwidth=2
" Workaround vim-commentary for Haskell
autocmd FileType haskell setlocal commentstring=--\ %s
" Workaround broken colour highlighting in Haskell
autocmd FileType haskell,rust setlocal nospell

" Move to the beginning when editing a git commit message
autocmd FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" Restore cursor to last edit position
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction
augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

" View the 80th line
if exists('+colorcolumn')
  set colorcolumn=81
  highlight ColorColumn ctermbg=16
  autocmd FileType gitcommit set colorcolumn=71
endif

" http://stackoverflow.com/a/29236158
function! CloseBuffer()
  let curBuf = bufnr('%')
  let curTab = tabpagenr()
  exe 'bnext'

  " If in the last buffer, create an empty buffer.
  if curBuf == bufnr('%')
    exe 'enew'
  endif

  " Loop through the tabs.
  for i in range(tabpagenr('$'))
    " Go to tab
    exe 'tabnext ' . (i + 1)
    " Store active window nr to restore later.
    let curWin = winnr()
    " Loop through windows pointing to buffer.
    let winnr = bufwinnr(curBuf)
    while (winnr >= 0)
      " Go to window and switch to next buffer.
      exe winnr . 'wincmd w | bnext'
      " Restore active window
      exe curWin . 'wincmd w'
      let winnr = bufwinnr(curBuf)
    endwhile
  endfor

  " Close buffer, restore active tab
  exe 'bd' . curBuf
  exe 'tabnext ' . curTab
endfunction

" https://github.com/vim-syntastic/syntastic/issues/1127
function! <SID>LocationPrevious()
  try
    lprev!
  catch /:E776:/ " No location list
  catch /:E553:/ " End/Start of location list
    call <SID>LocationLast()
  catch /:E926:/ " Location list changed
    ll!
  endtry
endfunction
function! <SID>LocationNext()
  try
    lnext!
  catch /:E776:/ " No location list
  catch /:E553:/ " End/Start of location list
    call <SID>LocationFirst()
  catch /:E926:/ " Location list changed
    call <SID>LocationNext()
  endtry
endfunction
function! <SID>LocationFirst()
  try
    lfirst!
  catch /:E926:/ " Location list changed
    call <SID>LocationFirst()
  endtry
endfunction
function! <SID>LocationLast()
  try
    llast!
  catch /:E926:/ " Location list changed
    call <SID>LocationLast()
  endtry
endfunction

let mapleader = ','

" Folding
set foldlevelstart=99
set foldmethod=indent
nnoremap <leader>f zA
vnoremap <leader>f zA

" Stop running the terminal
nmap K <nop>

" Wrappers for moving between windows
map <C-H> <C-W>h<C-W>_
map <C-L> <C-W>l<C-W>_
map <C-J> :bprev<CR>
map <C-K> :bnext<CR>

" Moving between syntastic errors
map <silent> <C-N> :call <SID>LocationNext()<CR>
map <silent> <C-M> :call <SID>LocationPrevious()<CR>

" Wrapped lines goes down/up to next row, rather than next line in file
nnoremap j gj
nnoremap k gk

" Yank from the cursor to the end of the line, to be consistent with C and D
nnoremap Y y$

nnoremap <silent> Q :call CloseBuffer()<CR>

" Clear the current search
nnoremap <silent> <leader>/ :nohlsearch<CR>

" Find merge conflict markers
nnoremap <leader>gc /\v^[<\|=>]{7}( .*\|$)<CR>

nnoremap <leader>o o<ESC>
nnoremap <leader>O O<ESC>

" Exit with an error code
nnoremap ZE :cq<CR>

" Redraw the screen
nnoremap <silent> <leader>r :redraw!<CR>

nnoremap <leader>vo :e $MYVIMRC<CR>
nnoremap <leader>vs :so $MYVIMRC<CR>

" Unite
try
    let g:unite_source_rec_async_command='ag --nocolor --nogroup --ignore ".git" --ignore "node_modules" --hidden -g ""'
    call unite#filters#matcher_default#use(['matcher_fuzzy'])
    call unite#filters#sorter_default#use(['sorter_length'])
catch
endtry
nnoremap <space>b :<C-u>Unite -buffer-name=buffer -start-insert buffer<CR>
nnoremap <space><space> :<C-u>Unite -start-insert file_rec/async:!<CR>
nnoremap <space>r <Plug>(unite_restart)
nnoremap <space>d <Plug>(unite_print_message_log)

command! W w
command! WQ wq
command! Wq wq

