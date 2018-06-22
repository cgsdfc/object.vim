let s:object = object#object_()
" FINAL CLASS: range {{{1
call object#class#builtin_class('range', s:object, s:)

function! s:range.__init__(start, stop, step)
  let self.start = a:start
  let self.stop = a:stop
  let self.step = a:step
endfunction

function! s:range.__iter__()
  return object#new(s:range_iterator, self) 
endfunction

function! s:range.__reversed__()

endfunction

function! s:range.__len__()
  return abs(self.stop - self.start)
endfunction

function! s:range.__contains__()

endfunction
" }}}1

" FINAL CLASS: range_iterator {{{1
call object#class#builtin_class('range_iterator', s:object, s:)

function! s:range_iterator.__init__(range)
  let self.range = a:range
  let self.idx = a:range.start
endfunction

function! s:range_iterator.__iter__()
  return self
endfunction

function! s:range_iterator.__next__()

endfunction
" }}}1

" FUNCTION: range() {{{1
function! object#range#range(...)

endfunction
" vim: set sw=2 sts=2 et fdm=marker:
