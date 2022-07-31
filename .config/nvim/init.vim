" === Plugins === "

" Specify a directory for plugins
call plug#begin('~/.vim/plugged')

    " Coding
    Plug 'neoclide/coc.nvim', {'branch': 'release'}                 " Code Completions
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
   
    " Visual
    Plug 'vim-airline/vim-airline'                                  " Status Bar
    Plug 'vim-airline/vim-airline-themes'                           " Status Bar Themes
    Plug 'ryanoasis/vim-devicons'                                   " Icons for various plugins

    " Tools
    Plug 'voldikss/vim-floaterm'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'donRaphaco/neotex', { 'for': 'tex' }

    " Debugging
    Plug 'mfussenegger/nvim-dap'
    Plug 'xianzhon/vim-code-runner'
    Plug 'rcarriga/nvim-dap-ui'

" Initialize plugin system
call plug#end()

" === Remaps === "

let mapleader = " "
" Escape replaced with "jk"
inoremap jk <ESC>
"xnoremap jk <ESC>
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" j/k will move virtual lines (lines that wrap)
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap <C-s> :w<CR>
nnoremap <C-Q> :wq<CR>
"inoremap <special> jk

" Buffer stuff
noremap <C-n> :bnext<CR>
noremap <C-b> :bprevious<CR> <ESC>

" New empty buffer
nmap <leader>T :enew<cr>

" Close the current buffer and move to the previous one
nmap <leader>bd :bp <BAR> bd #<CR>

" Close the current buffer and move to the previous one
nmap <leader>bD :bp <BAR> bd! #<CR>

" Show all open buffers and their status
nmap <leader>bl :ls<CR>

" Floaterm keybindings

" Open lf in floating terminal 
nmap <leader>f :FloatermNew --opener=edit lf<CR>

" Fuzzy find current buffer's DIR
nmap <leader>p :cd %:p:h <BAR> FloatermNew --opener=edit fzf<CR>

" Lazygit in buffer DIR 
nmap <leader>v :cd %:p:h <BAR> FloatermNew --opener=edit lazygit<CR>

" Live grep all files in directory
nmap <leader>g :cd %:p:h <BAR> FloatermNew --opener=edit ~/.config/scripts/floaterm_scripts/live_grep.sh<CR>

" Fuzzy find any file in /home or /media
nmap <leader>l :FloatermNew --opener=edit floaterm_wrapper $(fd -H . /home /run/media \| fzf --preview 'bat --style=numbers --color=always --line-range :500 {}')<CR>

" Open floating terminal to mess around, close when done
nmap <leader>t :cd %:p:h <BAR> FloatermNew --opener=edit<CR>


" === Zettelkasten functions ===

" Search file names
nmap <leader>zf :cd ~/Documents/Notes/<BAR> FloatermNew --opener=edit fzf<CR>

" Search file contents
nmap <leader>zg :cd ~/Documents/Notes/<BAR> FloatermNew --opener=edit ~/.config/scripts/floaterm_scripts/live_grep.sh<CR>

" Create new Zettel notes

" New Fleeting note
nmap <leader>znf :call NewZettel("f", "note")<CR>
" New Literature note
nmap <leader>znl :call NewZettel("l", "note")<CR>
" New Permanent note with note template
nmap <leader>znp :call NewZettel("p", "note")<CR>
" New Permanent note with index template
nmap <leader>znP :call NewZettel("p", "index")<CR>
" New Project note
nmap <leader>znj :call NewZettel("j", "note")<CR>

" Open master index
nmap <leader>zm :e ~/Documents/Notes/permanent/Master_Index.md<CR>
" Open todo list
nmap <leader>zt :e ~/Documents/Notes/permanent/TODO.md<CR>
" Open backburner todo list
nmap <leader>zT :e ~/Documents/Notes/permanent/TODO_Backburner.md<CR>

" Open and create new file with gn
nmap gn :call ZettelCreate('note')<CR>
nmap gN :call ZettelCreate('index')<CR>

function! NewZettel(f_type, template)
    let name = input("Enter a title for new note: ")
    let name = substitute(name, " ", "_", "")

    if a:f_type=="f"
        execute 'e ' . '~/Documents/Notes/fleeting/' . name . '.md'
    elseif a:f_type=="l"
        execute 'e ' . '~/Documents/Notes/literature/' . name . '.md'
    elseif a:f_type=="p"
        execute 'e ' . '~/Documents/Notes/permanent/' . name . '.md'
    elseif a:f_type=="j"
        execute 'e ' . '~/Documents/Notes/projects/' . name . '.md'
    endif

    let name = substitute(name, "_", " ", "")

    if a:template=="note"
        0put='# ' . name
        put=strftime('%c')
        put=''
        put=''
        put=''
        put='## References:'
        put='    1. '
        execute '4'
    elseif a:template=="index"
        0put='# ' . name
        put=''
        put='1. '
        execute '2'
        execute 'normal $'
    endif
endfunction

function! ZettelCreate(template)
    execute 'cd %:p:h'
    execute 'e <cfile>'
    let name = expand('%')
    let name = substitute(name, ".*/", " ", "")
    let name = substitute(name, "_", " ", "")
    let name = substitute(name, ".md", "", "")

    if a:template=="note"
        0put='# ' . name
        put=strftime('%c')
        put=''

        put=''
        put=''
        put='## References:'
        put='    1. '
        execute '4'
    elseif a:template=="index"
        0put='# ' . name
        put=''
        put='1. '
        execute '2'
        execute 'normal $'
    endif
endfunction

" Note:
"    "S(" to surround block with brackets
"    "gc" to comment out block

" Debugger

" Run code with F4
nnoremap <silent> <F4> <plug>CodeRunner                                                                     

" Start Debugger with F5
nnoremap <silent> <F5> :call DebugRunner()<CR>
nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
nnoremap <A-b> <Cmd>lua require'dap'.toggle_breakpoint()<CR>
nnoremap <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
" Open debugging UI with space"rd"
nmap <leader>dr :call DebuggerUIOpen()<CR>
nmap <leader>dl :lua require'dap'.run_last()<CR>

" Functions

let g:bool_ui_open=0
function! DebugRunner()
    if g:bool_ui_open==0
        let g:bool_ui_open=1
        execute "lua require'dapui'.setup() require'dapui'.open()"
        execute "lua require'dap'.continue()"
    elseif g:bool_ui_open==1
        execute "lua require'dap'.continue()"
    endif
endfunction

function! DebuggerUIOpen()
    if g:bool_ui_open==0
        let g:bool_ui_open=1
        execute "lua require'dapui'.setup() require'dapui'.open()"
    elseif g:bool_ui_open==1
        execute "lua require'dapui'.toggle()"
    endif
endfunction

function! PdfLatex()
    execute "!pdflatex %"
    execute "NeoTex"
    execute "!zathura *.pdf &"
endfunction

" Run code with rr
"nmap <leader>rr <plug>CodeRunner

" === Options === "

set updatetime=300          " don't give ins-completion-menu messages.
set shortmess+=c            " always show signcolumns
set signcolumn=yes
syntax on                   " Syntax highlighting
set hidden
set encoding=utf8
set history=5000
set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching 
set ignorecase              " case insensitive 
set smartcase
"set mouse=v                 " middle-click paste with 
set nohlsearch                " highlight search 
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab 
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right 
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set smartindent
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
set conceallevel=2          " Hide symbols for bold/italics when writing in markdown

" Use hybrid line numbers in normal mode, and absolute in insert mode
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

"  Navigate tmux panels with ctrl-hjkl
if exists('$TMUX')
  function! TmuxOrSplitSwitch(wincmd, tmuxdir)
    let previous_winnr = winnr()
    silent! execute "wincmd " . a:wincmd
    if previous_winnr == winnr()
      call system("tmux select-pane -" . a:tmuxdir)
      redraw!
    endif
  endfunction

  let previous_title = substitute(system("tmux display-message -p '#{pane_title}'"), '\n', '', '')
  let &t_ti = "\<Esc>]2;vim\<Esc>\\" . &t_ti
  let &t_te = "\<Esc>]2;". previous_title . "\<Esc>\\" . &t_te

  nnoremap <silent> <C-h> :call TmuxOrSplitSwitch('h', 'L')<cr>
  nnoremap <silent> <C-j> :call TmuxOrSplitSwitch('j', 'D')<cr>
  nnoremap <silent> <C-k> :call TmuxOrSplitSwitch('k', 'U')<cr>
  nnoremap <silent> <C-l> :call TmuxOrSplitSwitch('l', 'R')<cr>
else
  map <C-h> <C-w>h
  map <C-j> <C-w>j
  map <C-k> <C-w>k
  map <C-l> <C-w>l
endif

" === Airline settings === "

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_statusline_ontop=0
let g:airline_theme='bubblegum'

" === COC Settings === "

let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-pairs',
  \ 'coc-eslint', 
  \ 'coc-json',
  \ 'coc-clangd',
  \ 'coc-cmake',
  \ 'coc-html',
  \ 'coc-pyright',
  \ 'coc-rust-analyzer',
  \ ]

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <F2> <Plug>(coc-rename)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)

" === DAP Setup === "

lua <<EOF
local dap = require('dap')
dap.adapters.python = {
  type = 'executable';
  command = '/home/kai/.virtualenvs/cv/debugpy/bin/python';
  args = { '-m', 'debugpy.adapter' };
}

local dap = require('dap')
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
  name = 'lldb'
}

local dap = require('dap')
dap.configurations.python = {
  {
    -- The first three options are required by nvim-dap
    type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
    request = 'launch';
    name = "Launch file";

    -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

    program = "${file}"; -- This configuration will launch the current file if used.
    pythonPath = function() -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
      -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
      -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
      local cwd = vim.fn.getcwd()
      if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
        return cwd .. '/venv/bin/python'
      elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
        return cwd .. '/.venv/bin/python'
      else
        return '/usr/bin/python'
      end
    end;
  },
}
vim.fn.sign_define('DapBreakpoint', {text='✹', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapStopped', {text='→', texthl='', linehl='', numhl=''})

local dap = require('dap')
dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},

    -- 💀
    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
    --
    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    --
    -- Otherwise you might get the following error:
    --
    --    Error on launch: Failed to attach to the target process
    --
    -- But you should be aware of the implications:
    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
    -- runInTerminal = false,
  },
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

EOF
