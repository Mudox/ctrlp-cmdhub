" vim: foldmethod=marker

" GUARD {{{1
if exists("s:loaded") || &cp || version < 700
  finish
endif
let s:loaded = 1
" }}}1

command! CtrlPCmdHub cal ctrlp#init(ctrlp#cmdhub#id())

nnoremap <Plug>(ctrlp-cmdhub) :<C-U>CtrlPCmdHub<Cr>

let s:cmds_dir = get(g:, 'ctrlp_cmdhub_cmds_dir',
      \ expand('~/.vim/ctrlp-cmdhub-cmds'))
let s:cmds_dir = substitute(s:cmds_dir, '/$', '', '')

function ListCmdHubCommandFiles(lead, cmd, pos)
  let items = glob(printf('%s/*%s*.vim', s:cmds_dir, a:lead), 0, 1)
  call map(items, 'fnamemodify(v:val, ":t")')
  return items
endfunction

function CmdHubEditCommandFile()
  let fname = input('cmd file name: ', '', 'customlist,ListCmdHubCommandFiles')
  if empty(fname) | return | endif

  if fname !~ '\.vim$'
    let fname .= '.vim'
  endif

  silent! execute '!mkdir -p '. s:cmds_dir
  call mudox#query_open_file#New(s:cmds_dir . '/' . fname)
endfunction

function CmdHubExecuteCommandFrom(fname)
  let command_file_name = a:fname =~ '\.vim$' ?
        \ a:fname : a:fname . '.vim'

  let command_file_path = s:cmds_dir . '/' . command_file_name
  if empty(glob(command_file_path))
    echoerr '* cmdhub: missing command file: ' . command_file_path
    return
  endif

  execute 'source ' . command_file_path
endfunction
