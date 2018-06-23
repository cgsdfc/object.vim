let s:object = object#object_()

" CLASS: zip {{{1
call object#class#builtin_class('zip', s:object, s:)

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

" }}}1

""
" @function zip(...)
" Return an iterator that zips a list of sequences.
" >
"   zip(iter[,*iters]) -> [seqn1[0], seqn2[0], ...], ...
"   zip() -> an empty iterator
" <
" The iterator stops at the shortest sequence.
function! object#zip#zip(...)
  return object#new_(s:zip, a:000)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
