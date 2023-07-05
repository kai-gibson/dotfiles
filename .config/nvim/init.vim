" Specify a directory for plugins
call plug#begin('~/.vim/plugged')

    " Coding
    Plug 'neoclide/coc.nvim', {'branch': 'release'}  " Code Completions
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/playground'
   
    " Visual
    "Plug 'vim-airline/vim-airline'          " Status Bar
    "Plug 'vim-airline/vim-airline-themes'   " Status Bar Themes
    "Plug 'ryanoasis/vim-devicons'           " Icons for various plugins
    "Plug 'dstein64/vim-startuptime'
    "Plug 'bling/vim-bufferline'

    " Tools
    Plug 'voldikss/vim-floaterm'
    " Plug 'tpope/vim-surround'
    " Plug 'tpope/vim-commentary'
    Plug 'dhruvasagar/vim-table-mode'   
    Plug 'donRaphaco/neotex', { 'for': 'tex' }

    " Debugging
    Plug 'mfussenegger/nvim-dap'
    Plug 'rcarriga/nvim-dap-ui'

" Initialize plugin system
call plug#end()


" === Remaps === "



let mapleader = " "

" Escape replaced with "jk"
inoremap jk <ESC>
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Mimic Emacs Line Editing in Insert Mode
inoremap <C-A> <Home>
inoremap <C-B> <Left>
inoremap <C-E> <End>
inoremap <C-f> <Right>
inoremap <A-b> <C-Left>
inoremap <A-f> <C-Right>
inoremap <C-K> <Esc>lDa
inoremap <C-U> <Esc>d0xi
inoremap <A-d> <Esc>dwi
inoremap <A-Backspace> <Esc>dbxa

" Paste from clipboard
noremap <C-p> "+p
" Copy to clipboard
noremap <C-y> "+y

" Buffer stuff
nnoremap <C-n> :bnext<CR>
nnoremap <C-b> :bprevious<CR>

" Close the current buffer
nmap <leader>bd :bd<CR>
" Force close the current buffer
nmap <leader>bD :bd!<CR>

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

" Extending 'g'
" Open file in split
map gs :above wincmd f<cr>
map gv :vertical wincmd f<cr>

" Note:
"    "S(" to surround block with brackets
"    "gc" to comment out block

" === Debugging Remaps ===

" Run code with F4
"
nnoremap <leader>x :!compiler %<CR>
nnoremap <silent> <F4> :!compiler %<CR>
" nnoremap <silent> <F4> <plug>CodeRunner                                                                     
" Start Debugger with F5
nnoremap <silent> <F5> :call DebugRunner()<CR>
nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
nnoremap <A-b> <Cmd>lua require'dap'.toggle_breakpoint()<CR>
nnoremap <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
" Open debugging UI with space'rd'
nmap <leader>dr :call DebuggerUIOpen()<CR>
nmap <leader>dl :lua require'dap'.run_last()<CR>

" Functions

function TestLua()
    v:lua.example_func()
endfunction

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

" === Options === "

packadd termdebug

let g:termdebug_wide=1
set updatetime=300          " Don't give ins-completion-menu messages.
set shortmess+=c            " Always show signcolumns
set signcolumn=yes
hi SignColumn ctermbg=none  " no bg colour for signcolumn
syntax on                   " Syntax highlighting
set hidden
set encoding=utf8
set history=5000
set nocompatible            " Disable compatibility to old-time vi
set showmatch               " Show matching 
set ignorecase              " Case insensitive 
set smartcase
set nohlsearch              " Don't highlight search 
set incsearch               " Incremental search
set tabstop=4               " Number of columns occupied by a tab 
set softtabstop=4           " See multiple spaces as tabstops so <BS> does the right 
set expandtab               " Converts tabs to white space
set shiftwidth=4            " Width for autoindents
set autoindent              " Indent a new line the same amount as the line just typed
set smartindent
set number                  " Add line numbers
set wildmode=longest,list   " Get bash-like tab completions
filetype plugin indent on   " Allow auto-indenting depending on file type
syntax on                   " Syntax highlighting
set mouse=a                 " Enable mouse click
filetype plugin on
set cursorline              " Highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
set conceallevel=2          " Hide symbols for bold/italics when writing in markdown
set textwidth=72
set colorcolumn=73
highlight ColorColumn ctermbg=blue
hi Floaterm guibg=black
" test


autocmd BufNewFile,BufRead * setlocal formatoptions-=cro
" Use hybrid line numbers in normal mode, and absolute in insert mode
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" === Airline settings === "

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_statusline_ontop=0
let g:airline_theme='bubblegum'

" === COC Settings === "
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-eslint', 
  \ 'coc-json',
  \ 'coc-clangd',
  \ 'coc-cmake',
  \ 'coc-html',
  \ 'coc-pyright',
  \ 'coc-rust-analyzer',
  \ 'coc-tsserver',
  \ ]

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <F2> <Plug>(coc-rename)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

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

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "lua", "rust", "python", "markdown", "nix"},

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { "javascript" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled

    disable = { "markdown" },
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
EOF

