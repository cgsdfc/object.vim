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
    call object#TypeError("cannot unpack arguments")
  endif
  let i = 0
  while i < len(a:formal)
    let {a:formal[i]} = a:actual[i]
    let i += 1
  endwhile
  unlet i
  return l:
endfunction

function! object#Lib#callable#UnpackIterator(iter, args) abort "{{{1
  " Unpack `args` into `iter` such that
  " ```for key, val in dict.items()
  " or for i in dict.items()```
  " both work.
  if len(a:iter) == 1
    let {a:iter[0]} = a:args
  elseif len(a:iter) == len(a:args)
    let i = 0
    while i < len(a:iter)
      let {a:iter[i]} = a:iter[i]
      let i += 1
    endwhile
    unlet i
  else
    call object#TypeError("cannot unpack arguments")
  endif
  return l:
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
