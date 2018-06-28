" CLASS: zip {{{1
let s:zip = object#Lib#builtins#Type_New('zip')

function! s:zip.__init__(...)
  let self._seqns = map(copy(a:000), 'object#iter(v:val)')
endfunction

let s:zip.__iter__ = object#slots#iter_self()
let s:zip.__setattr__ = object#slots#readonly_attribute()

function! s:zip.__next__()
  if empty(self._seqns)
    call object#StopIteration()
  endif
  return map(copy(self._seqns), 'object#next(v:val)')
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
