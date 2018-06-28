" CLASS: map {{{1
let s:map = object#Lib#builtins#Type_New('map')

function! s:map.__init__(callable, ...)
  if !a:0
    call object#TypeError("map() must have at least two arguments")
  endif
  " Note: It does not check it immediately.
  let self._callable = a:callable
  let self._seqns = map(copy(a:000), 'object#iter(v:val)')
endfunction

let s:map.__iter__ = object#slots#iter_self()
let s:map.__setattr__ = object#slots#readonly_attribute()

function! s:map.__next__()
  return object#builtin#Call_(self._callable,
        \ map(copy(self._seqns), 'object#next(v:val)'))
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
