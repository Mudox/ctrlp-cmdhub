" vim: foldmethod=marker

" GUARD                                                                             {{{1
if exists("s:loaded") || &cp || version < 700
  finish
endif
let s:loaded = 1
" }}}1

let s:menu_file_path = expand('~/.ctrlp-cmdhub')

function EditCmdHubMenuFile()
  call Qpen(s:menu_file_path)
endfunction

" center repository to hold registered items, not those in menu file.
let g:registered_items = {}

" Users use this function to register their commands, where
"   title - short string to describe the command, must be unique over all
"           other titles.
"   cmd   - ex-command without ':' prefix
function cmdhub#core#register(title, cmd)                                         " {{{1
  let title_cmd_dict = cmdhub#core#title_cmd_dict()
  if ! has_key(title_cmd_dict, a:title)
    let g:registered_items[a:title] = a:cmd
  else
    echoerr printf("Dupliate title found:\nnew: [%s] -> %s\nold: [%s] -> %s",
          \ a:title, a:cmd, a:title, title_cmd_dict[a:title])
  end
endfunction "  }}}1

let s:menu_file_template_path = expand('<sfile>:p:h')
      \. '/../../menu_file_template'

" helper method to add key uniquely to a dict
function s:add_uniquely(dict, title, cmd)
  if ! has_key(a:dict, a:title)
    let a:dict[a:title] = a:cmd
  else
    echohl WarningMsg
    echo printf("dupliate title found:\nnew: [%s] -> %s\nold: [%s] -> %s",
          \ a:title, a:cmd, a:title, a:dict[a:title])
    echo "ignore the new one ..."
    echohl None
  end
endfunction

function cmdhub#core#title_cmd_dict()                                             " {{{1
  " items are come from 3 places:
  " 1. registered items stored in g:registered_items
  " 2. menu items saved in menu file s:menu_file_path
  " 3. items auto-collected under path s:jobs_dir

  let title_cmd_dict = copy(g:registered_items)


  " if menu file not exists, create & populate it with initial content.
  if !filereadable(s:menu_file_path)
    let template = readfile(s:menu_file_template_path)
    call writefile(template, s:menu_file_path)
  endif

  " collect items from menu file                                                       {{{2

  " read & filter out empty & comment lines.
  let lines = filter(readfile(s:menu_file_path),
        \ 'v:val !~ "^\\s*$" && v:val !~ "^#"')

  " split each line by tabs.
  let title_cmd_tuples = filter(map(lines, 'split(v:val, "\\t\\+")'),
        \ '! empty(v:val)')

  " add to title_cmd_dict dict
  for [title, cmd] in title_cmd_tuples
    call s:add_uniquely(title_cmd_dict, title, cmd)
  endfor

  " }}}2

  " collect items form job dir                                                         {{{2
  let jobs_dir = get(g:, 'ctrlp_cmdhub_jobs_dir',
        \ expand('~/.ctrlp-cmdhub-jobs'))
  let jobs_dir = substitute(jobs_dir, '/$', '', '')

  let files = glob(jobs_dir . '/*.vim', 0, 1)
  if empty(files)
    return title_cmd_dict
  endif

  for fn in files
    " read first 2 lines
    " title line must stay in the first 2 lines
    let first_2_lines = readfile(fn, '', 2)
    let ok = 0
    for l in first_2_lines
      let pattern = '^"\s*cmdhub:'
      if l =~ pattern
        let ok = 1
        let title = substitute(l, pattern, '', '')
        let title = substitute(title, '^\s*\(.*\)\s*$', '\1', '')
        break " inner for
      endif
    endfor

    if !ok
      echohl
      echo '* can not find cmdhub title line in first 2 lines of file: '
            \ . fn
      echohl None
      break " outer for
    endif

    let cmd = printf('call CmdHubExecuteJobFrom("%s")', fn)
    call s:add_uniquely(title_cmd_dict, title, cmd)
  endfor

  " }}}2

  return title_cmd_dict
endfunction " }}}1
