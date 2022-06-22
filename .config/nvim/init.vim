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
    Plug 'airblade/vim-gitgutter'                                   " Shows changes in gutter
    
    " Tools
    Plug 'voldikss/vim-floaterm'

    " Debugging
    Plug 'mfussenegger/nvim-dap'
    Plug 'xianzhon/vim-code-runner'
    Plug 'rcarriga/nvim-dap-ui'

" Initialize plugin system
call plug#end()

" === Remaps === "

let mapleader = " "
inoremap jk <ESC>
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

" Show all open buffers and their status
nmap <leader>bl :ls<CR>

" Floaterm keybindings

" Open lf in floating terminal 
nmap <leader>f :FloatermNew --opener=edit lf<CR>

" Fuzzy find current buffer's DIR
nmap <leader>p :cd %:p:h <BAR> FloatermNew --opener=edit fzf<CR>

" Lazygit in buffer DIR 
nmap <leader>g :cd %:p:h <BAR> FloatermNew --opener=edit lazygit<CR>

" Fuzzy find any file in /home or /media
nmap <leader>l :FloatermNew --opener=edit floaterm_wrapper $(fd -H . /home \| fzf --preview 'bat --style=numbers --color=always --line-range :500 {}')<CR>

" Debugger

" Run code with F4
nnoremap <silent> <F4> <plug>CodeRunner                                                                     

" Start Debugger with F5
nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
nnoremap <silent> <Leader>b <Cmd>lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
" Open debugging UI with space"rd"
nmap <leader>dr :call DebuggerUIOpen()<CR>
nmap <leader>dl :lua require'dap'.run_last()<CR>

let g:bool_ui_open=0
function! DebuggerUIOpen()
    if g:bool_ui_open==0
        let g:bool_ui_open=1
        execute "lua require'dapui'.setup() require'dapui'.open()"
    elseif g:bool_ui_open==1
        execute "lua require'dapui'.toggle()"
    endif
endfunction


" Run code with rr
nmap <leader>rr <plug>CodeRunner

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
  \ 'coc-texlab',
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
-- If you want to use this for Rust and C, add something like this:

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

EOF
