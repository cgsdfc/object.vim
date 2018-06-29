let s:filter = object#Lib#builtins#IteratorType_New('filter')

" Note: Currently predicate doesn't support None.
" Use function('object#bool') instead.
function! s:filter.__init__(predicate, iterable)
  let self._predicate = a:predicate
  let self._iterable = object#iter(a:iterable)
endfunction

function! s:filter.__next__()
  while 1
    let N = object#next(self._iterable)
    if object#bool(object#Lib#func#Call(self._predicate, N))
      return N
    endif
  endwhile
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
