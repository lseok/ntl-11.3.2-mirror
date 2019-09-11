
command! -nargs=* CscopeRun call CscopeDBRun(<f-args>)

nmap ;h :call CscopeDBHelp()<CR>
nmap ;s :CscopeRun 0 __C_Symbol____       <C-R>=expand("<cword>")<CR><CR> 
nmap ;g :CscopeRun 1 __Definition____     <C-R>=expand("<cword>")<CR><CR> 
nmap ;d :CscopeRun 2 __Called_By_This____ <C-R>=expand("<cword>")<CR><CR> 
nmap ;c :CscopeRun 3 __Calling_This____   <C-R>=expand("<cword>")<CR><CR> 
nmap ;t :CscopeRun 4 __Text_String____    <C-R>=expand("<cword>")<CR><CR> 
nmap ;e :CscopeRun 6 __Egrep____          <C-R>=expand("<cword>")<CR><CR> 
nmap ;f :CscopeRun 7 __This_File____      <C-R>=expand("<cfile>")<CR><CR> 
nmap ;i :CscopeRun 8 __Including_This____ <C-R>=expand("<cfile>")<CR><CR> 

nmap ;;s :cs find 0 <C-R>=expand("<cword>")<CR><CR> 
nmap ;;g :cs find 1 <C-R>=expand("<cword>")<CR><CR> 
nmap ;;d :cs find 2 <C-R>=expand("<cword>")<CR><CR> 
nmap ;;c :cs find 3 <C-R>=expand("<cword>")<CR><CR> 
nmap ;;t :cs find 4 <C-R>=expand("<cword>")<CR><CR> 
nmap ;;e :cs find 6 <C-R>=expand("<cword>")<CR><CR> 
nmap ;;f :cs find 7 <C-R>=expand("<cfile>")<CR><CR> 
nmap ;;i :cs find 8 <C-R>=expand("<cfile>")<CR><CR> 

nmap ;S :CscopeRun 0 __C_Symbol____       <C-R>=input("Enter word:")<CR><CR> 
nmap ;G :CscopeRun 1 __Definition____     <C-R>=input("Enter word:")<CR><CR> 
nmap ;D :CscopeRun 2 __Called_By_This____ <C-R>=input("Enter word:")<CR><CR> 
nmap ;C :CscopeRun 3 __Calling_This____   <C-R>=input("Enter word:")<CR><CR> 
nmap ;T :CscopeRun 4 __Text_String____    <C-R>=input("Enter word:")<CR><CR> 
nmap ;E :CscopeRun 6 __Egrep____          <C-R>=input("Enter word:")<CR><CR> 
nmap ;F :CscopeRun 7 __This_File____      <C-R>=input("Enter word:")<CR><CR> 
nmap ;I :CscopeRun 8 __Including_This____ <C-R>=input("Enter word:")<CR><CR> 

nmap ;;S :cs find s 
nmap ;;G :cs find g 
nmap ;;D :cs find d 
nmap ;;C :cs find c 
nmap ;;T :cs find t 
nmap ;;E :cs find e 
nmap ;;F :cs find f 
nmap ;;I :cs find i 

function! CscopeDBSet(prj_home)
    if ! has("cscope") || strlen(a:prj_home) == 0
        return
    endif

    set cst 
    set csto=0
    set csprg=cscope
    set cspc=0

    call CscopeDBAdd(a:prj_home)
    "let cscope_file = a:prj_home . "/src/cscope.out"
    "if filereadable(cscope_file)
    "  execute "cs add " . cscope_file . " " . a:prj_home . "/src"
    "endif

    "quick fix window 사용할 목록
    "set cscopequickfix=c-,s-,t-,e-,i-,g-,d-
    "set timeoutlen=2000
    "set ttimeout
    "set ttimeoutlen=100
endfunction

function! CscopeDBAdd(prj_home)
    if ! has("cscope") || strlen(a:prj_home) == 0
        return
    endif

    set nocsverb
    let cscope_file = a:prj_home . "/cscope.out"
    if filereadable(cscope_file)
      execute "cs add " . cscope_file
    endif
    set csverb
endfunction


function! CscopeDBHelp()
    echohl WarningMsg | echo ";h This Help Message" | echohl None
    echo ";s (0 or s) Find this C symbol"
    echo ";g (1 or g) Find this definition"
    echo ";d (2 or d) Find functions called by this function"
    echo ";c (3 or c) Find functions calling this function"
    echo ";t (4 or t) Find this text string"
    echo ";e (6 or e) Find this egrep pattern"
    echo ";f (7 or f) Find this file"
    echo ";i (8 or i) Find files #including this file"
endfunction


function! CscopeDBRun(...)
    if ! exists("g:prj_cur_home") || ! exists("a:1") || ! exists("a:2") || ! exists("a:3")
        return
    endif

    let src_home = g:prj_cur_home."/src"
    let cs_opt = a:1
    let cs_msg = a:2
    let cs_pattern = a:3

    let cmd = "cscope -d -P".src_home." -f".src_home."/cscope.out -i".src_home."/cscope.files -L -".cs_opt." ".cs_pattern." | awk '{print $1,$3,$2}'"

    let cmd_output = system(cmd)

    if cmd_output == ""
            echohl WarningMsg | 
            \ echomsg "Error: Pattern " . cs_pattern . " not found" | 
            \ echohl None
            return
    endif

    if a:1 == 1
        exe "ptag "a:3
        silent! wincmd P
        exe "silent! normal zRzz"
        wincmd p
        return
    endif

    let tmpfile = tempname()
    exe "redir! > " . tmpfile
    silent echon expand("%")." ".line(".")." ".cs_msg.cs_pattern."\n"
    silent echon cmd_output
    redir END

    let old_efm = &efm
    "set efm=%f\ %*[^\ ]\ %l\ %m
    set efm=%f\ %l\ %m

    "7.0이상에서 지원하는 location list 사용
    if v:version >= 700
        let lfile = "lfile"
        let ldisp = "ll"
    else
        let lfile = "cfile"
        let ldisp = "cc"

    endif

    exe "silent! ".lfile." " . tmpfile

    if v:version >= 700
        lopen
    else
        copen
    endif

    if a:1 == 7
        exe ldisp." 2"
    else
        exe ldisp." 1"
    endif

    call delete(tmpfile)

    let &efm = old_efm
endfunction

