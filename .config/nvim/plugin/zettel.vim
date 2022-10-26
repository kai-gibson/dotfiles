" === Zettelkasten ===
"
" Open and create new file with gn
nmap gn :call ZettelCreate('note')<CR>
nmap gN :call ZettelCreate('index')<CR>
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
" New Project note
nmap <leader>znJ :call NewZettel("j", "index")<CR>
" New Diary Entry
nmap <leader>zd :call NewZettel("d", "diary")<CR>

" Open master index
nmap <leader>zm :e ~/Documents/Notes/permanent/Master_Index.md<CR>
" Open todo list
nmap <leader>zt :e ~/Documents/Notes/permanent/TODO.md<CR>
" Open backburner todo list
nmap <leader>zT :e ~/Documents/Notes/permanent/TODO_Backburner.md<CR>

function! NewZettel(f_type, template)
    if a:f_type!="d"
        let name = input("Enter a title for new note: ")
        let name = substitute(name, " ", "_", "g")

        if a:f_type=="f"
            execute 'e ' . '~/Documents/Notes/fleeting/' . name . '.md'
        elseif a:f_type=="l"
            execute 'e ' . '~/Documents/Notes/literature/' . name . '.md'
        elseif a:f_type=="p"
            execute 'e ' . '~/Documents/Notes/permanent/' . name . '.md'
        elseif a:f_type=="j"
            execute 'e ' . '~/Documents/Notes/projects/' . name . '.md'
        endif

        let name = substitute(name, "_", " ", "g")

        call ZettelTemplate(a:template, name)

    elseif a:f_type=="d"
        let name = expand('`date +"%Y-%m-%d"`')
        execute 'e ' . '~/Documents/Notes/diary/' . name . '.md'

        " If the file doesn't exist, create it with a template
        if empty(glob("~/Documents/Notes/diary/" . name . ".md"))
            call ZettelTemplate(a:template, name)
        endif
    endif
endfunction

function! ZettelCreate(template)
    execute 'cd %:p:h'
    execute 'e <cfile>'
    let name = expand('%')
    let name = substitute(name, ".*/", " ", "")
    let name = substitute(name, "_", " ", "g")
    let name = substitute(name, ".md", "", "")

    call ZettelTemplate(a:template, name)
endfunction

function! ZettelTemplate(template, name)
    if a:template=="note"
        0put='# ' . a:name
        put=strftime('%c')
        put=''
        put=''
        put=''
        put='## References:'
        put='    1. '
        execute '4'
    elseif a:template=="diary"
        0put='# ' . a:name
        put=strftime('%c')
        put=''
        put=''
        put=''
        put='## Completed TODO:'
        execute '4'
    elseif a:template=="index"
        0put='# ' . a:name
        put=''
        put='1. '
        execute '2'
        execute 'normal $'
    endif
endfunction
