function! object#Lib#callable#Lambda_New(...) abort "{{{1
  " Since `builtins.lambda` is a type while `object#lambda()`
  " is a function that returns `Funcref`, we need this wrapper.
  let lmbd = object#Lib#builtins#Object_New_('lambda', a:000)
  return function('object#Objects#lambda#Eval', [lmbd])
endfunction

function! object#Lib#callable#UnpackArgs(formal, actual) abort "{{{1
  " Unpack `actual` into `formal` in such a list that,
  " [[formal1, actual1], ...]
  if len(a:formal) != len(a:actual)
    call object#TypeError("cannot unpack %d arguments to %d names",
          \ len(a:actual), len(a:formal))
  endif
  let args = []
  let i = 0
  while i < len(a:formal)
    call add(args, [a:formal[i], a:actual[i]])
    let i += 1
  endwhile
  return args
endfunction

"
" Execute {__excmds} with {__items} set as items
" from the iterator.
function! object#Lib#callable#execute_cmds(__excmds, __items, __closure)
  let c = a:__closure
  for __i in a:__items
    let {__i[0]} = __i[1]
  endfor
  execute a:__excmds
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
