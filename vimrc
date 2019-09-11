let s:script_dir = expand("<sfile>:p:h")

execute "set path+=" . s:script_dir . "/**"
set tagrelative

execute "set tags=" . s:script_dir . "/tags"

let g:prj_cur_home=$NTL_HOME

exe "so ".s:script_dir . "/cscope.vim"
call CscopeDBSet(g:prj_cur_home)

"cscope quick fix window 연동 default ON
if ! exists("unuse_cscope") || unuse_cscope == 0
    exe "so ".s:script_dir . "/cscope.vim"
    call CscopeDBSet(g:prj_cur_home)
endi
