" FINAL CLASS: callable_iterator {{{1
let s:callable_iterator = object#Lib#builtin#Type_New('callable_iterator')
let s:callable_iterator.__final__ = 1

function! s:callable_iterator.__init__(callable, sentinel)
  let self.callable = a:callable
  let self.sentinel = a:sentinel
endfunction

let s:callable_iterator.__iter__ = object#slots#iter_self()

" TODO: self.callable can be method of other object,
" but it will forget the original self after put into
" callable_iterator.
" The callable module can detect this and create a method
" wrapper.
function! s:callable_iterator.__next__()
  let Next = object#builtin#CallFuncref(self.callable)
  if Next ==# self.sentinel
    call object#StopIteration()
  endif
  return Next
endfunction
" }}}1

" vim: set sw=2 sts=2 et fdm=marker:
