" CLASS: filter {{{1
let s:filter = object#Lib#builtins#Type_New('filter')

" Note: Currently predicate doesn't support None.
" Use function('object#bool') instead.
function! s:filter.__init__(predicate, iterable)
  let self._predicate = a:predicate
  let self._iterable = object#iter(a:iterable)
endfunction

let s:filter.__iter__ = object#slots#iter_self()
let s:filter.__setattr__ = object#slots#readonly_attribute()

function! s:filter.__next__()
  while 1
    let N = object#next(self._iterable)
    if object#bool(object#builtin#Call(self._predicate, N))
      return N
    endif
  endwhile
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
