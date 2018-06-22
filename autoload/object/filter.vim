let s:object = object#object_()

" CLASS: filter {{{1
call object#class#builtin_class('filter', s:object, s:)

" Note: Currently predicate doesn't support None.
" Use function('object#bool') instead.
function! s:filter.__init__(predicate, iterable)
  let self.predicate = a:predicate
  let self.iterable = object#iter(a:iterable)
endfunction

function! s:filter.__iter__()
  return self
endfunction

function! s:filter.__next__()
  while 1
    let N = object#next(self.iterable)
    if object#bool(object#builtin#Call(self.predicate, N))
      return N
    endif
  endwhile
endfunction
" }}}1

" FUNCTION: filter() {{{1
""
" @function filter(...)
function! object#filter#filter(...)
  return object#new_(s:filter, a:000)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
