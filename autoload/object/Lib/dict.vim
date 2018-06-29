function! object#Lib#dict#Dict_New(...) abort "{{{1
  return object#Lib#func#Call('object#Lib#dict#Dict_NewImpl', a:000)
endfunction

function! object#Lib#dict#Dict_NewImpl(...) abort "{{{1
  " ```
  " dict() -> an empty dictionary.
  " dict(iterable) -> initiazed with 2-list items.
  " dict(plain dictionary) -> a copy of the argument.
  " dict(dict object) -> a copy of the underlying dictionary.
  " ```
  call object#Lib#value#TakeAtMostOptional('dict', 1, a:0)
  if !a:0
    return {}
  endif
  if object#Lib#value#IsDict(a:1)
    return copy(a:1)
  endif
  let iter = object#iter(a:1)
  let res = {}
  try
    while 1
      let N = object#next(iter)
      let res[N[0]] = N[1]
    endwhile
  catch 'StopIteration'
    return res
  endtry
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
