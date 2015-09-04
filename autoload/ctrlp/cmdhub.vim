" vim: foldmethod=marker

" =============================================================================
" File:          autoload/ctrlp/cmdhub.vim
" Description:   Example extension for ctrlp.vim
" =============================================================================

" GUARD                                                                             {{{1
if exists("s:loaded") || &cp || version < 700
  finish
endif
let s:loaded = 1
" }}}1

" Add this extension's settings to g:ctrlp_ext_vars
"
" Required:
"
" + init: the name of the input function including the brackets and any
"         arguments
"
" + accept: the name of the action function (only the name)
"
" + lname & sname: the long and short names to use for the statusline
"
" + type: the matching type
"   - line : match full line
"   - path : match full line like a file or a directory path
"   - tabs : match until first tab character
"   - tabe : match until last tab character
"
" Optional:
"
" + enter: the name of the function to be called before starting ctrlp
"
" + exit: the name of the function to be called after closing ctrlp
"
" + opts: the name of the option handling function called when initialize
"
" + sort: disable sorting (enabled by default when omitted)
"
" + specinput: enable special inputs '..' and '@cd' (disabled by default)

call add(g:ctrlp_ext_vars, {
      \  'init':   'ctrlp#cmdhub#init()',
      \  'exit':   'ctrlp#cmdhub#exit()',
      \  'accept': 'ctrlp#cmdhub#accept',
      \  'lname':  'cmdhub',
      \  'sname':  'cmdhub',
      \  'type':   'line',
      \  'sort':   0,
      \  'nolim':  1,
      \ })


" Provide a list of strings to search in
"
" Return: a Vim's List


function! ctrlp#cmdhub#init()
  let s:title_cmds = cmdhub#cmds#all_items()
  return keys(s:title_cmds)
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string

function! ctrlp#cmdhub#accept(mode, str)
  let cmd = s:title_cmds[a:str]
  call ctrlp#exit()
  redraw!
  execute cmd
endfunction

" (optional) Do something before enterting ctrlp
function! ctrlp#cmdhub#enter()
endfunction

" (optional) Do something after exiting ctrlp
function! ctrlp#cmdhub#exit()
  unlet! s:title_cmds
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#cmdhub#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#cmdhub#id()
  return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/cmdhub.vim
" command! CtrlPCmdHub call ctrlp#init(ctrlp#cmdhub#id())
