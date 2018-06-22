let s:object = object#object_()

" CLASS: map {{{1
call object#class#builtin_class('map', s:object, s:)

function! s:map.__init__(callable, ...)
  if !a:0
    call object#TypeError("map() must have at least two arguments")
  endif
  " Note: It does not check it immediately.
  let self.callable = a:callable
  let self.seqns = map(copy(a:000), 'object#iter(v:val)')
endfunction

function! s:map.__iter__()
  return self
endfunction

function! s:map.__next__()
  return object#builtin#Call_(self.callable,
        \ map(copy(self.seqns), 'object#next(v:val)'))
endfunction
" }}}1

" FUNCTION: map() {{{1
""
" @function map(...)
function! object#map#map(...)
  return object#new_(s:map, a:000)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
