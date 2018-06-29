function! object#Lib#callable#Lambda_New(...) abort "{{{1
  " Since `builtins.lambda` is a type while `object#lambda()`
  " is a function that returns `Funcref`, we need this wrapper.
  let lmbd = object#Lib#builtins#Object_New_('lambda', a:000)
  return function('object#Objects#lambda#Eval', [lmbd])
endfunction

function! s:UnpackList(names, args) "{{{1
  let i = 0
  while i < len(a:names)
    let {a:names[i]} = a:args[i]
    let i += 1
  endwhile
  unlet i
  return l:
endfunction

function! object#Lib#callable#UnpackArgs(formal, actual) abort "{{{1
  " Unpack `actual` into `formal` in such a list that,
  " [[formal1, actual1], ...]
  if len(a:formal) != len(a:actual)
    call object#TypeError("cannot unpack arguments")
  endif
  return s:UnpackList(a:formal, a:actual)
endfunction

function! object#Lib#callable#UnpackIterator(iter, args) abort "{{{1
  " Unpack `args` into `iter` such that
  " ```for key, val in dict.items()
  " or for i in dict.items()```
  " both work.
  if len(a:iter) == 1
    return {a:iter[0]: a:args}
  elseif len(a:iter) == len(a:args)
    return s:UnpackList(a:iter, a:args)
  else
    call object#TypeError("cannot unpack arguments")
  endif
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
