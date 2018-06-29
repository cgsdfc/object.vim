
""
" Execute a |List| of commands while iterating over {iterable}.
" {names} is a space-separated |String|s that contains the variable
" names used as the items in the {iterable}. If a [closure] is given,
" it is available as `c.var` inside the code.
"
" {cmd} is a |String| of Ex command or a |List| of such strings.
" During each iteration, the commands are executed
" in the order that they are specified in the list.
" Examples:
" >
"   call object#for('x', range(10), ['if x > 0', 'echo x', 'endif'])
"   call object#for('f', files, 'call f.close()')
"   call object#for('key val', items(dict), 'echo key val')
" <
function! object#callable#lambda#for(names, iterable, cmds, ...)
  " TODO: use for object
  call object#util#ensure_argc(1, a:0)
  let names = object#callable#lambda#make_names(a:names)
  let iter = object#iter(a:iterable)
  let closure = a:0 ? maktaba#ensure#IsDict(a:1) : {}

  if maktaba#value#IsString(a:cmds)
    let excmds = a:cmds
  else
    let excmds = join(map(
          \ maktaba#ensure#IsList(a:cmds), 'maktaba#ensure#IsString(v:val)'), "\n")
  endif

  try
    while 1
      let Items = object#callable#lambda#make_items(names, object#next(iter))
      call object#callable#lambda#execute_cmds(excmds, Items, closure)
    endwhile
  catch /StopIteration/
    return
  endtry
endfunction

function! object#callable#lambda#ensure_unique(names)
  let seen = {}
  for x in a:names
    if !has_key(seen, x)
      let seen[x] = 1
      continue
    endif
    throw object#ValueError('duplicate name %s', string(x))
  endfor
  return a:names
endfunction

