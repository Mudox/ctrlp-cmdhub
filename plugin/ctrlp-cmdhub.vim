" vim: foldmethod=marker

" GUARD {{{1
if exists("s:loaded") || &cp || version < 700
  finish
endif
let s:loaded = 1
" }}}1

command CtrlPCmdHub call ctrlp#init(ctrlp#cmdhub#id())

nnoremap <Plug>(ctrlp-cmdhub) :<C-U>CtrlPCmdHub<Cr>

let g:ctrlp_cmdhub_jobs_dir = get(g:, 'ctrlp_cmdhub_jobs_dir',
      \ expand('~/.ctrlp-cmdhub-jobs'))
let g:ctrlp_cmdhub_jobs_dir = substitute(g:ctrlp_cmdhub_jobs_dir, '/$', '', '')

let s:jobs_dir = g:ctrlp_cmdhub_jobs_dir

if s:jobs_dir[len(s:jobs_dir) -1] == '/'
  let s:jobs_dir = s:jobs_dir[:-2]
endif

" completion helper
function ListCmdHubJobFiles(lead, cmd, pos)
  let items = glob(printf('%s/*%s*.vim', s:jobs_dir, a:lead), 0, 1)
  call map(items, 'fnamemodify(v:val, ":t")')
  return items
endfunction

function CmdHubEditJobFile()
  let fname = input('cmd file name: ', '', 'customlist,ListCmdHubJobFiles')
  if empty(fname) | return | endif

  if fname !~ '\.vim$'
    let fname .= '.vim'
  endif

  silent! execute '!mkdir -p '. s:jobs_dir
  call Qpen(s:jobs_dir . '/' . fname)
endfunction

function CmdHubExecuteJobFrom(fname)
  if empty(glob(a:fname))
    echohl WarningMsg
    echo 'ctrlp-cmdhub: missing job file ' . a:fname
    echohl None
    return
  endif

  execute 'source ' . a:fname
endfunction
