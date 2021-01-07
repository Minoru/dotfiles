" .vimrc
" Author: Alexander Batischev <eual.jp@gmail.com>
" Source: https://github.com/Minoru/dotfiles

" Vim-plug {{{{

call plug#begin('~/.vim/plugins')
Plug 'scrooloose/nerdcommenter'
Plug 'aklt/plantuml-syntax'
Plug 'MarcWeber/vim-addon-local-vimrc'
Plug 'godlygeek/tabular'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'tpope/vim-fugitive'
Plug 'raichoo/purescript-vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'cespare/vim-toml'
Plug 'plasticboy/vim-markdown'
Plug 'pbrisbin/vim-syntax-shakespeare'
Plug 'elmcast/elm-vim'
Plug 'udalov/kotlin-vim'
Plug 'arrufat/vala.vim'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'ledger/vim-ledger'
Plug 'anekos/hledger-vim' " for omni-completion
Plug 'kongo2002/fsharp-vim'
call plug#end()

" }}}}
" Plugin settings {{{{
" clang_complete {{{{
let g:clang_snippets_engine="ultisnips"
let g:clang_conceal_snippets=0
let g:clang_close_preview=1
" }}}}
" vim-markdown {{{{
" Highlight YAML frontmatter (used in Hakyll posts)
let g:vim_markdown_frontmatter = 1
" }}}}
" }}}}
" Indentation and the like {{{{

" more sophisticated than autoindent; does the same as autoindent + use syntax
" to add/remove tabs if necessary
set smartindent

" 4 spaces == 1 tab
set tabstop=4
set softtabstop=4
set shiftwidth=4

set smarttab
set expandtab " Use spaces, not tabs

" Insert one space between sentences, not two
set nojoinspaces
" Allow comments formatting with "gq"
set formatoptions=q
" auto-wrap text using textwidth
set formatoptions+=t
" auto-wrap comments
set formatoptions+=c
" insert comment leader on i_Enter, o and O
set formatoptions+=ro
" recognize numbered lists
set formatoptions+=n
" don't break lines after a one-letter word
set formatoptions+=1
" remove comment leader when joining lines (if that makes sense)
set formatoptions+=j
" do not auto-wrap lines that were already longer than 'textwidth' when we
" entered Insert mode
set formatoptions+=b
" There's really no downside to enabling this:
" 1. In Markdown and other text files, this will spell-check everything;
" 2. In code, this will only check string literals and comments.
set spell
set spelllang+=en,ru_yo

" }}}}
" Appearance {{{{

"Folding settings
set foldmethod=syntax
set foldnestmax=3 " deepest fold is 3 levels
set foldenable " do fold by default
set foldlevelstart=0 " start with all folds closed

" put new split windows at the right and below
set splitright
set splitbelow

set background=dark " Background is dark
syntax on " Enable syntax hilighting
colorscheme minoru " use self-written colorscheme
" Funtoo enables search highlighting by default
" That won't be much of a problem if only Vim didn't restore the search
" pattern, which in conjunction with hls leads to searches being highlighted
" right after opening the file, which is annoying
set nohls
set scrolloff=3 " keep at least 3 lines above/below the cursor visible
" show partial command in the ruler
set showcmd
" line numbers would be calculated relatively to the current line
set relativenumber
" dropdown menu should have blue background
highlight Pmenu ctermbg=0 ctermfg=2
" Highlight VCS (git, at least) conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'
"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
" TODO: put this and all the following `autocmd`s into appropriate autocmd
" groups
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'commit'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

" The following is just a slightly tweaked Gentoo's default statusline
set statusline=   " clear the statusline for when vimrc is reloaded
set statusline+=%-3.3n\                      " buffer number
set statusline+=%f\                          " file name
set statusline+=%h%m%r%w                     " flags
set statusline+=[%{strlen(&ft)?&ft:'none'},  "   filetype
set statusline+=%{strlen(&fenc)?&fenc:&enc}, "   encoding
set statusline+=%{&fileformat}]              "   file format
set statusline+=%=                           " right align
set statusline+=%-14.(%l,%c%V%)\ %<%P        " offset

" }}}}
" Mappings {{{{

" Following Steve Losh' advice:
" http://learnvimscriptthehardway.stevelosh.com/chapters/10.html
inoremap jk <esc>
" ...and one variation, since I can't seem to release Shift in time...
inoremap Jk <esc>

" move by screen line instead of file line
nnoremap j gj
nnoremap k gk
" I rarely need the default behaviour, but let's provide some shortcuts just
" in case
noremap gj j
noremap gk k

" Save the pinkies!
nnoremap ; :
nnoremap : ;

" some Emacs mappings that I do like (got used to them using shell)
inoremap <c-a> <esc>I
inoremap <c-e> <esc>A
cnoremap <c-a> <home>
cnoremap <c-e> <end>

" Sudo to write
cnoremap w!! w !sudo tee % >/dev/null

" Easy buffer navigation
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" Gentoo maps this to a function that toggles 'ai' and 'list' - this helps
" when you want to copy from Vim. I don't use this stuff, therefore...
" (`silent!` to avoid error messages about undefined mapping)
silent! nunmap <F3>
silent! iunmap <F3>
silent! cunmap <F3>
" ...but I liked the key, so...
set pastetoggle=<F3>
" (I've been using <leader>p, with <leader> mapped to backslash, for quite
" a while, but it inevitably caused problems, most often with LaTeX sources)

" }}}}
" Miscellaneous {{{{

set autochdir " current dir determined by current buffer
" undofiles preserve undo history between edits (i.e. you can close vim)
" Note two slashes at the end -- this makes Vim create swapfile's name from
" the full path to the edited file, ensuring their uniqueness.
set undofile undodir=~/.vim/undofiles//
" just in case, autocreate undodir if it doesn't exist
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif
" store swap files away from the edited files. This helps with slow
" filesystems, e.g. DAV. See the comment above re two slashes
set directory=~/.vim/swapfiles//,~/tmp//,/var/tmp//,/tmp//
if !isdirectory(expand("~/.vim/swapfiles"))
    call mkdir(expand("~/.vim/swapfiles"), "p")
endif

set modeline " read configuration parameters from current file

set gdefault " replace globally by default
" Search
set incsearch " Increment search: update found items while typing pattern

set smartcase " ignore case only if all letters are in lower case
set ignorecase " need to be set in order for 'smartcase' to work

" use sane regexes
nnoremap / /\v
vnoremap / /\v

"Omni completion
filetype plugin on
set omnifunc=syntaxcomplete#Complete

set encoding=utf-8 " default encoding
" sequences of encodings and file formats to try
set fileencodings=utf-8,windows-1251
set fileformats=unix,dos,mac

" assume all numbers are decimal (affects CTRL-A and CTRL-X)
set nrformats=

" try making the TUI faster
set lazyredraw ttyfast

" backspace over autoindent, eol and the start of the insert
set backspace=indent,eol,start

" show line wraps with some nice Unicode
set showbreak=↪

" automatically reload the file if it was changed outside of Vim (but hasn't
" been changed in Vim)
set autoread

" Don't try to highlight lines longer than 800 characters.
set synmaxcol=200

" Better Completion
set complete=.,w,b,u,t
set completeopt=longest,menuone,preview

" Wildmenu completion
set wildmenu
set wildmode=full

set wildignore+=.hg,.git                         " Version control
set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.o,*.obj                        " compiled object files
set wildignore+=*.spl                            " compiled spelling word lists
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=*.hi                             " Haskell's "interactive files"

" in Visual block mode, allow selecting places where there's no chars
set virtualedit+=block

" enable mouse in Normal and Insert modes. That allows for scrolling and
" click-to-put-cursor, the only worthwhile uses for mouse in Vim
set mouse=ni

" }}}}
" Language-specific preferences {{{{

" C/C++ {{{{

augroup ft_c
    autocmd!

    " Look for tags file from here and up the tree until home
    autocmd FileType c,cc,cpp,h,hpp,s setlocal tags+=tags;$HOME

    " Recognize Doxygen-style comments
    " Cf. https://stackoverflow.com/a/28078855/2350060
    autocmd FileType c,cc,cpp,h,hpp,s setlocal comments^=:///

    " Highlight symbols in the column farther than the column 79; better than
    " 'colorcolumn' setting because it doesn't display annoying vertical red bar.
    "
    " The last parameter to matchadd() is priority; it prioritizes this rule so
    " high it would (hopefully) work no matter what other rules there is (i.e.
    " no other rule would change the highlighting)
    autocmd FileType c,cc,cpp,h,hpp,s call matchadd('ColorColumn', '\%>79v', 100)

    " fold by blocks
    autocmd FileType c setlocal foldmethod=marker foldmarker={,}

augroup END

" }}}}
" CSS {{{{

augroup ft_css
    autocmd!

    au Filetype css setlocal foldmethod=marker
    au Filetype css setlocal foldmarker={,}
    au Filetype css setlocal omnifunc=csscomplete#CompleteCSS

augroup END

" }}}}
" Java {{{{

augroup ft_java
    autocmd!

    autocmd FileType java setlocal foldmethod=marker
    autocmd FileType java setlocal foldmarker={,}

augroup END

" }}}}
" JavaScript {{{{

augroup ft_javascript
    autocmd!

    autocmd FileType javascript setlocal foldmethod=marker
    autocmd FileType javascript setlocal foldmarker={,}

augroup END

" }}}}
" Haskell {{{{

augroup ft_haskell
    autocmd!

    " 2-space tabs
    autocmd FileType haskell,lhaskell setlocal tabstop=2 softtabstop=2 shiftwidth=2
    " disable folding
    autocmd FileType haskell,lhaskell setlocal nofoldenable
    " make % work inside code like (\(x, y) -> x + y)
    " https://www.reddit.com/r/haskell/comments/4k8iy5/til_when_using_vim_to_edit_haskell_setlocal/
    autocmd FileType haskell,lhaskell setlocal cpoptions+=M
    " highlight everything farther than 80th column
    autocmd FileType haskell,lhaskell call matchadd('ColorColumn', '\%>79v', 100)
    " replace tabs with nice Unicode symbols
    autocmd FileType haskell,lhaskell exec "set listchars=tab:\uBB\uBB,extends:❯,precedes:❮"
    autocmd FileType haskell,lhaskell setlocal list
    " remove trailing whitespace upon write
    autocmd FileType haskell,lhaskell exec "au BufWritePre  <buffer> exec \"    %substitute/\\\\s\\\\+$//e\""
    autocmd FileType haskell,lhaskell exec "au FileWritePre <buffer> exec \"'[,']substitute/\\\\s\\\\+$//e\""

augroup END

" }}}}
" Erlang {{{{
augroup ft_erlang
    autocmd!

    " 2-space tabs
    autocmd FileType erlang setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd FileType erlang call matchadd('ColorColumn', '\%>79v', 100)
augroup END
" }}}}
" Python {{{{

augroup ft_python
    autocmd!

    " folding by indent
    autocmd FileType python setlocal foldmethod=indent
    " PEP8
    " 4 spaces for indentation
    autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4
    autocmd FileType python setlocal expandtab
    " limit lines to 79 characters
    autocmd FileType python setlocal textwidth=79
    autocmd FileType python call matchadd('ColorColumn', '\%>79v', 100)

augroup END

" }}}}
" Perl {{{{

augroup ft_perl
    autocmd!

    " 2 spaces for indentation
    autocmd FileType perl setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd FileType perl setlocal expandtab
    " do not remove indent for lines starting with #
    autocmd FileType perl inoremap # X#

augroup END

" }}}}
" Shell {{{{

augroup ft_shell
    autocmd!

    " do not remove indent for lines starting with #
    autocmd FileType sh inoremap # X#

augroup END

" }}}}
" Crontab, fstab, make {{{{

augroup ft_crontab_fstab_make
    autocmd!

    " use real tabs
    autocmd FileType crontab,fstab,make setlocal noet tabstop=8 shiftwidth=8

augroup END

" }}}}
" emails {{{{

augroup ft_mail
    autocmd!

    " constrain text width to 72 chars
    autocmd FileType mail setlocal textwidth=72
    " do not insert quote leader after hitting 'o' or 'O' in Normal mode
    autocmd FileType mail setlocal formatoptions-=o
    autocmd FileType mail setlocal formatoptions+=aw
    " disable folding
    autocmd FileType mail setlocal nofoldenable

augroup END

" }}}}
" git commits {{{{

augroup ft_git_commit
    autocmd!

    " enable spellchecking for English
    autocmd FileType gitcommit setlocal spell spelllang=en

    " disable folding
    autocmd FileType gitcommit setlocal nofoldenable

    " start at the end of the first line
    autocmd FileType gitcommit normal! gg$

augroup END

" }}}}
" vimrc {{{{

augroup ft_vim
    autocmd!

    " folding by markers
    autocmd FileType vim setlocal foldenable foldmethod=marker

augroup END

" }}}}
" Markdown {{{

augroup ft_markdown
    autocmd!

    " Markdown filenames end in .md
    autocmd BufRead,BufNewFile *.md setlocal filetype=markdown

    " limit text width to 80
    autocmd BufRead,BufNewFile *.md setlocal textwidth=80

    " disable folding
    autocmd BufRead,BufNewFile *.md setlocal nofoldenable

augroup END

" }}}
" {{{ LaTeX and TeX

augroup ft_tex
    autocmd!

    autocmd FileType tex setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
    autocmd FileType tex setlocal textwidth=80

augroup END

" }}}
" Awk {{{{

augroup ft_awk
    autocmd!

    " do not remove indent for lines starting with #
    autocmd FileType awkj inoremap # X#

augroup END

" }}}}
" Go {{{{

augroup ft_golang
    autocmd!

    autocmd FileType go setlocal noexpandtab tabstop=8 softtabstop=0 shiftwidth=0

augroup END

" }}}}
" Hledger {{{{

augroup ft_ledger
    autocmd!

    " omni-completion from hledger-vim, because it works better than
    " vim-ledger
    autocmd FileType ledger setlocal omnifunc=hledger#complete#omnifunc

augroup END

" }}}
" }}}}
" Local config with machine-specific settings {{{{

" Use local config when available
" TODO: use hostname instead of 'local', so that local-specific configs can be
" checked in into main dotfiles repo without colissions.
if filereadable(".vimrc.local")
  " one thing one might add to .vimrc.local on machines that have multicore
  " CPUs: read :h gzip-example and use `pigz` instead of `gzip`
  source .vimrc.local
endif
" }}}}
