call plug#begin()

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rails'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'klen/nvim-test'
Plug 'vim-ruby/vim-ruby'
Plug 'w0rp/ale'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'jlanzarotta/bufexplorer'
Plug 'nvim-lua/plenary.nvim' 
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-tree/nvim-web-devicons'

Plug 'nvim-neo-tree/neo-tree.nvim'
Plug 'MunifTanjim/nui.nvim'

Plug 'Rigellute/rigel'

" Initialize plugin system
call plug#end()

syntax on
set termguicolors
syntax enable
colorscheme rigel

let g:ale_set_highlights = 0

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

" open files in the current directory
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

" close a buffer in a split without closing the split
command! BD bn\|bd \# <cr>

" write with sudo
cmap w!! w !sudo tee % > /dev/null

" run ctags with exclusions
cmap ctags ctags --exclude=.git --exclude=.github --exclude=node_modules --exclude=public --exclude=log -R *

" Rspec.vim mappings
map <Leader>r :TestFile<CR>
map <Leader>s :TestNearest<CR>
map <Leader>l :TestLast<CR>
map <Leader>a :TestSuite<CR>

" NeoTree toggle
map <Leader>n :NeoTreeFocusToggle<CR>

" fix pre ruby 1.9 hash syntax
command! Fh :%s/:\([^ ]*\)\(\s*\)=>/\1:/gc

" stop those pesky swp warnings
:set noswapfile
:set nobackup
:set nowritebackup

map [b :bp<cr>
map ]b :bn<cr>

nnoremap <C-t> :GFiles<Cr>
nnoremap <C-g> :Ag<Cr>

map <Leader>f :ALEFix<Cr>

" Start Neotree when nvim is started without file arguments.
if empty(argv())
  au VimEnter * Neotree
endif

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files path=%:p:h<cr>
nnoremap <leader>fb <cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fbf <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" don't hide quotes in json
let g:vim_json_syntax_conceal = 0

" set shell=/usr/local/bin/zsh
set shell=/usr/bin/bash

let g:ale_fixers = {
      \   'javascript': ['eslint'],
      \   'ruby': ['rubocop'],
      \}
let g:copilot_node_command = "~/.asdf/shims/node"

lua <<EOF

require("telescope").load_extension "file_browser"
require("neo-tree").setup({
  source_selector = {
    winbar = true,
    statusline = false
  }
}) 
require("nvim-test").setup({
  run = true,                 -- run tests (using for debug)
  commands_create = true,     -- create commands (TestFile, TestLast, ...)
  filename_modifier = ":.",   -- modify filenames before tests run(:h filename-modifiers)
  silent = false,             -- less notifications
  term = "terminal",          -- a terminal to run ("terminal"|"toggleterm")
  termOpts = {
    direction = "vertical",   -- terminal's direction ("horizontal"|"vertical"|"float")
    width = 96,               -- terminal's width (for vertical|float)
    height = 24,              -- terminal's height (for horizontal|float)
    go_back = false,          -- return focus to original window after executing
    stopinsert = "auto",      -- exit from insert mode (true|false|"auto")
    keep_one = true,          -- keep only one terminal for testing
  },
  runners = {               -- setup tests runners
    ruby = "nvim-test.runners.rspec",
  }
})

EOF

