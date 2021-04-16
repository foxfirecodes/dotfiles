" Plugins {{{
call plug#begin('~/.local/share/nvim/plugged')

" -- Completion & linting
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" -- Navigation
Plug 'Shougo/denite.nvim'
Plug 'preservim/nerdtree'
Plug 'ruanyl/vim-gh-line'

" -- Syntax
Plug 'HerringtonDarkholme/yats.vim'
Plug 'pantharshit00/vim-prisma'

" -- UI Widgets
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'

" -- Themes & styling
Plug 'sonph/onehalf', {'rtp': 'vim/'}
Plug 'ryanoasis/vim-devicons'

" -- File support
Plug 'vim-scripts/JavaDecompiler.vim'

call plug#end()
" }}}

" Tabs {{{
set expandtab
set tabstop=4
set shiftwidth=4

autocmd Filetype yaml setlocal tabstop=2 shiftwidth=2
" }}}

" Binds {{{

nmap <tab> :bnext<CR>
nmap <s-tab> :bprev<CR>

map <c-x><c-x> :bdel<CR>
map <c-x><c-s> :w<CR>

map <leader>e :NERDTreeToggle<CR>

" https://superuser.com/a/321726
" delete without yanking
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" replace currently selected text with default register
" without yanking it
vnoremap <leader>p "_dP

" -- coc.nvim
" use tab & shift-tab to cycle through completions
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" use ctrl-space to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" use enter to select completion
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" show documentation
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" formatting selected code
xmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" }}}

" Auto Commands {{{

autocmd BufWritePost ~/.Xresources :silent !xrdb -merge ~/.Xresources
autocmd CursorHold * silent call CocActionAsync('highlight')

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" }}}

" Visual {{{
" Doesn't work (well) with urxvt
" set termguicolors

if has('termguicolors')
    set termguicolors

    set t_8f=[38;2;%lu;%lu;%lum
    set t_8b=[48;2;%lu;%lu;%lum
endif

set number

if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

colorscheme onehalfdark
let g:airline_theme='onehalfdark'

let g:gitgutter_async = 0
set updatetime=100

" Force background transparency despite colorscheme
hi Normal             ctermbg=NONE guibg=NONE
hi Statement          ctermbg=NONE guibg=NONE
hi Title              ctermbg=NONE guibg=NONE
hi Todo               ctermbg=NONE guibg=NONE
hi Underlined         ctermbg=NONE guibg=NONE
hi ErrorMsg           ctermbg=NONE guibg=NONE
hi LineNr             ctermbg=NONE guibg=NONE

" Un-derpify popup menus
hi Pmenu ctermbg=black guibg=black ctermfg=lightgray guifg=lightgray

" }}}

" Quality of Life {{{

" Folding
set foldmethod=marker

" Don't be stupid
set hidden
set nocompatible

" Better searching
set ignorecase
set smartcase

set shortmess+=c

let g:gh_use_canonical=0

" }}}

" Airline {{{

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 2

let g:airline_powerline_fonts = 1

" }}}

" Denite {{{

" Courtesy of: https://github.com/ctaylo21/jarvis

try
    " === Denite setup ==="
    " Use ripgrep for searching current directory for files
    " By default, ripgrep will respect rules in .gitignore
    "   --files: Print each file that would be searched (but don't search)
    "   --glob:  Include or exclues files for searching that match the given glob
    "            (aka ignore .git files)
    "
    call denite#custom#var('file/rec', 'command', ['rg', '--files', '--glob', '!.git'])

    " Use ripgrep in place of "grep"
    call denite#custom#var('grep', 'command', ['rg'])

    " Custom options for ripgrep
    "   --vimgrep:  Show results with every match on it's own line
    "   --hidden:   Search hidden directories and files
    "   --heading:  Show the file name above clusters of matches from each file
    "   --S:        Search case insensitively if the pattern is all lowercase
    call denite#custom#var('grep', 'default_opts', ['--hidden', '--vimgrep', '--heading', '-S'])

    " Recommended defaults for ripgrep via Denite docs
    call denite#custom#var('grep', 'recursive_opts', [])
    call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
    call denite#custom#var('grep', 'separator', ['--'])
    call denite#custom#var('grep', 'final_opts', [])

    " Remove date from buffer list
    call denite#custom#var('buffer', 'date_format', '')

    " Custom options for Denite
    "   auto_resize             - Auto resize the Denite window height automatically.
    "   prompt                  - Customize denite prompt
    "   direction               - Specify Denite window direction as directly below current pane
    "   winminheight            - Specify min height for Denite window
    "   highlight_mode_insert   - Specify h1-CursorLine in insert mode
    "   prompt_highlight        - Specify color of prompt
    "   highlight_matched_char  - Matched characters highlight
    "   highlight_matched_range - matched range highlight
    let s:denite_options = {'default' : {
                \ 'split': 'floating',
                \ 'start_filter': 1,
                \ 'auto_resize': 1,
                \ 'source_names': 'short',
                \ 'prompt': '$ ',
                \ 'statusline': 0,
                \ 'highlight_matched_char': 'QuickFixLine',
                \ 'highlight_matched_range': 'Visual',
                \ 'highlight_window_background': 'Visual',
                \ 'highlight_filter_background': 'DiffAdd',
                \ 'winrow': 1,
                \ 'vertical_preview': 1
                \ }}

    " Loop through denite options and enable them
    function! s:profile(opts) abort
        for l:fname in keys(a:opts)
            for l:dopt in keys(a:opts[l:fname])
                call denite#custom#option(l:fname, l:dopt, a:opts[l:fname][l:dopt])
            endfor
        endfor
    endfunction

    call s:profile(s:denite_options)
catch
    echo 'Denite not installed. It should work after running :PlugInstall'
endtry

" === Denite shorcuts === "
"   ;         - Browser currently open buffers
"   <leader>t - Browse list of files in current directory
"   <leader>g - Search current directory for occurences of given term and close window if no results
"   <leader>j - Search current directory for occurences of word under cursor
nmap ; :Denite buffer<CR>
nmap <leader>t :DeniteProjectDir file/rec<CR>
nnoremap <leader>g :<C-u>Denite grep:. -no-empty<CR>
nnoremap <leader>j :<C-u>DeniteCursorWord grep:.<CR>

" Define mappings while in 'filter' mode
"   <C-o>         - Switch to normal mode inside of search results
"   <Esc>         - Exit denite window in any mode
"   <CR>          - Open currently selected file in any mode
"   <C-t>         - Open currently selected file in a new tab
"   <C-v>         - Open currently selected file a vertical split
"   <C-h>         - Open currently selected file in a horizontal split
autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
    imap <silent><buffer> <C-o>
                \ <Plug>(denite_filter_quit)
    inoremap <silent><buffer><expr> <Esc>
                \ denite#do_map('quit')
    nnoremap <silent><buffer><expr> <Esc>
                \ denite#do_map('quit')
    inoremap <silent><buffer><expr> <CR>
                \ denite#do_map('do_action')
    inoremap <silent><buffer><expr> <C-t>
                \ denite#do_map('do_action', 'tabopen')
    inoremap <silent><buffer><expr> <C-v>
                \ denite#do_map('do_action', 'vsplit')
    inoremap <silent><buffer><expr> <C-h>
                \ denite#do_map('do_action', 'split')
endfunction

" Define mappings while in denite window
"   <CR>        - Opens currently selected file
"   q or <Esc>  - Quit Denite window
"   d           - Delete currenly selected file
"   p           - Preview currently selected file
"   <C-o> or i  - Switch to insert mode inside of filter prompt
"   <C-t>       - Open currently selected file in a new tab
"   <C-v>       - Open currently selected file a vertical split
"   <C-h>       - Open currently selected file in a horizontal split
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
    nnoremap <silent><buffer><expr> <CR>
                \ denite#do_map('do_action')
    nnoremap <silent><buffer><expr> q
                \ denite#do_map('quit')
    nnoremap <silent><buffer><expr> <Esc>
                \ denite#do_map('quit')
    nnoremap <silent><buffer><expr> d
                \ denite#do_map('do_action', 'delete')
    nnoremap <silent><buffer><expr> p
                \ denite#do_map('do_action', 'preview')
    nnoremap <silent><buffer><expr> i
                \ denite#do_map('open_filter_buffer')
    nnoremap <silent><buffer><expr> <C-o>
                \ denite#do_map('open_filter_buffer')
    nnoremap <silent><buffer><expr> <C-t>
                \ denite#do_map('do_action', 'tabopen')
    nnoremap <silent><buffer><expr> <C-v>
                \ denite#do_map('do_action', 'vsplit')
    nnoremap <silent><buffer><expr> <C-h>
                \ denite#do_map('do_action', 'split')
endfunction

" }}}

" NERDTree {{{

autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let g:NERDTreeDirArrowExpandable = ''
let g:NERDTreeDirArrowCollapsible = ''
let g:NERDTreeQuitOnOpen = 1

" }}}
