let s:map = object#Lib#builtins#IteratorType_New('map')

function! s:map.__init__(callable, ...) "{{{1
  if !a:0
    call object#TypeError("map() must have at least two arguments")
  endif
  " Note: It does not check it immediately.
  let self._callable = a:callable
  let self._seqns = map(copy(a:000), 'object#iter(v:val)')
endfunction

function! s:map.__next__() "{{{1
  return object#builtin#Call_(self._callable,
        \ map(copy(self._seqns), 'object#next(v:val)'))
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
