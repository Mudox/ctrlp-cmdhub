" vim: foldmethod=marker

" GUARD                                                                             {{{1
if exists("s:loaded") || &cp || version < 700
  finish
endif
let s:loaded = 1
" }}}1

let s:data_file_path = expand('~/.ctrlp-cmdhub')

function EditCmdHubDataFile()
  call mudox#query_open_file#New(s:data_file_path)
endfunction

" center repository to hold registered items, not those in data file.
let g:registered_items = {}

" Users use this function to register their commands, where
"   title - short string to describe the command, must be unique over all
"           other titles.
"   cmd   - ex-command without ':' prefix
function cmdhub#cmds#register(title, cmd)                                         " {{{1
  let all_items = cmdhub#cmds#all_items()
  if ! has_key(all_items, a:title)
    let g:registered_items[a:title] = a:cmd
  else
    echoerr printf("Dupliate title found:\nnew: [%s] -> %s\nold: [%s] -> %s",
          \ a:title, a:cmd, a:title, all_items[a:title])
  end
endfunction "  }}}1

let s:data_file_template_path = expand('<sfile>:p:h')
      \. '/../../data_file_template'

function cmdhub#cmds#all_items()                                                 " {{{1
  let all_items = copy(g:registered_items)

  " if data file not exists, create & populate it with initial content.
  if !filereadable(s:data_file_path)
    let template = readfile(s:data_file_template_path)
    call writefile(template, s:data_file_path)
  endif

  " read & filter out empty & comment lines.
  let lines = filter(readfile(s:data_file_path),
        \ 'v:val !~ "^\\s*$" && v:val !~ "^#"')

  " transform '#command_file_name' to
  " 'call CmdHubExecuteCommandFrom("command_file_name")
  for i in range(len(lines))
    let lines[i] = substitute(lines[i], '\t\zs#\(.*\)$',
          \ 'call CmdHubExecuteCommandFrom("\1")', '')
  endfor

  " split each line by tabs.
  let title_cmd_tuples = filter(map(lines, 'split(v:val, "\\t\\+")'),
        \ '! empty(v:val)')

  " add to all_items dict
  for [title, cmd] in title_cmd_tuples
    if ! has_key(all_items, title)
      let all_items[title] = cmd
    else
      echoerr printf("Dupliate title found:\nnew: [%s] -> %s\nold: [%s] -> %s",
            \ title, cmd, title, all_items[title])
    end
  endfor

  return all_items
endfunction " }}}1
