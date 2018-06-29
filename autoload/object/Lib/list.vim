function! object#Lib#list#List_New(...) abort "{{{1
  return object#Lib#func#Call('object#Lib#list#List_NewImpl', a:000)
endfunction

function! object#Lib#list#List_NewImpl(...) abort "{{{1
  " Create a plain |List|.
  " >
  "   list() -> an empty list.
  "   list(plain list) -> a shallow copy of it.
  "   list(iterable) -> initiazed with items of iterable.
  "   list(list object) -> a copy of the underlying list.
  " <
  call object#builtin#TakeAtMostOptional('list', 1, a:0)
  if !a:0
    return []
  endif

  if object#builtin#IsList(a:1)
    return copy(a:1)
  endif

  let iter = object#iter(a:1)
  let list = []
  try
    while 1
      call add(list, object#next(iter))
    endwhile
  catch 'StopIteration'
    return list
  endtry
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
