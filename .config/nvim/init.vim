call plug#begin()

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rails'
"Plug 'thoughtbot/vim-rspec'
Plug 'vim-ruby/vim-ruby'
"Plug 'easymotion/vim-easymotion'
Plug 'w0rp/ale'
Plug 'posva/vim-vue'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-commentary'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-surround'
Plug 'leafgarland/typescript-vim'
Plug 'lepture/vim-jinja'
Plug 'preservim/nerdtree'
Plug 'kien/ctrlp.vim'
Plug 'skalnik/vim-vroom'
Plug 'jlanzarotta/bufexplorer'

Plug 'wesgibbs/vim-irblack'

" Initialize plugin system
call plug#end()

syntax on

let g:ale_set_highlights = 0
colorscheme busierbee

filetype plugin indent on
set number
set tabstop=2
set shiftwidth=2
set expandtab
set backspace=indent,eol,start
set signcolumn=yes

"scrolling maxes out all cores at the mo without this
"https://github.com/vim/vim/issues/2584
set nocursorline 

"statusline setup
set statusline =%#identifier#
set statusline+=[%f]    "tail of the filename
set statusline+=%*

"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

set statusline+=%h      "help file flag
set statusline+=%y      "filetype

"read only flag
set statusline+=%#identifier#
set statusline+=%r
set statusline+=%*

"modified flag
set statusline+=%#warningmsg#
set statusline+=%m
set statusline+=%*

set statusline+=%{fugitive#statusline()}

"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
set laststatus=2

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
  if !exists("b:statusline_trailing_space_warning")

    if !&modifiable
      let b:statusline_trailing_space_warning = ''
      return b:statusline_trailing_space_warning
    endif

    if search('\s\+$', 'nw') != 0
      let b:statusline_trailing_space_warning = '[\s]'
    else
      let b:statusline_trailing_space_warning = ''
    endif
  endif
  return b:statusline_trailing_space_warning
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
  let nums = sort(a:nums)
  let l = len(nums)

  if l % 2 == 1
    let i = (l-1) / 2
    return nums[i]
  else
    return (nums[l/2] + nums[(l/2)-1]) / 2
  endif
endfunction

" We have to have a winheight bigger than we want to set winminheight. But if
" we set winheight to be huge before winminheight, the winminheight set will
" fail.
set winwidth=84
set winheight=5
set winminheight=5
set winheight=999

set wildmenu
set wildmode=list:longest

" taken from: http://stackoverflow.com/questions/356126/how-can-you-automatically-remove-trailing-whitespace-in-vim/1618401#1618401
fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfun

" auto-strip trailing white space for ruby files
" autocmd BufWritePre *.rb :call <SID>StripTrailingWhitespaces()
autocmd FileType c,cpp,java,php,ruby,python,haml,html,javascript,scss,sass,feature,yaml,typescript,vue,erb,tf autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

nnoremap <leader><leader> <c-^>
map <Leader>m :RTmodel
map <Leader>c :RTcontroller
map <Leader>v :RTview
command! Rroutes :tabe config/routes.rb

" open routes and gemfile in their own split
map <leader>gr :topleft :split config/routes.rb<cr>
map <leader>gg :topleft 100 :split Gemfile<cr>

" open files in the current directory
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

" close a buffer in a split without closing the split
command! BD bn\|bd \# <cr>

" write with sudo
cmap w!! w !sudo tee % > /dev/null

" Rspec.vim mappings
" let g:rspec_runner = "os_x_iterm2"
" let g:rspec_command = "Dispatch bundle exec ./bin/rspec {spec} --color"
" let g:rspec_command = "Dispatch bundle exec rspec {spec} --color"
" map <Leader>t :call RunCurrentSpecFile()<CR>
" map <Leader>s :call RunNearestSpec()<CR>
" map <Leader>l :call RunLastSpec()<CR>
" map <Leader>a :call RunAllSpecs()<CR>

" fix pre ruby 1.9 hash syntax
command! Fh :%s/:\([^ ]*\)\(\s*\)=>/\1:/gc

" stop those pesky swp warnings
:set noswapfile
:set nobackup
:set nowritebackup

" Gif config
" map  / <Plug>(easymotion-sn)
" omap / <Plug>(easymotion-tn)
" map  n <Plug>(easymotion-next)
" map  N <Plug>(easymotion-prev)

map [b :bp<cr>
map ]b :bn<cr>

nnoremap <C-t> :GFiles<Cr>
nnoremap <C-g> :Ag<Cr>

map <Leader>f :ALEFix<Cr>

" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

" CtrlP settings
let g:ctrlp_max_files=5000
let g:ctrlp_custom_ignore = '\v[\/](.github|coverage|log|node_modules|storage|tmp)|(\.(swp|ico|git|gif|png|jpg))$'

" don't hide quotes in json
let g:vim_json_syntax_conceal = 0

" set shell=/usr/local/bin/zsh
set shell=/usr/bin/bash

let g:ale_fixers = {
      \   'javascript': ['eslint'],
      \   'ruby': ['rubocop'],
      \}
let g:user_emmet_leader_key=','
let g:copilot_node_command = "~/.nodenv/shims/node"

" NVim vim-vroom terminal mode
let g:vroom_use_terminal = 1
