let s:callable_iterator = object#Lib#builtins#IteratorType_New('callable_iterator')
let s:callable_iterator.__final__ = 1

function! s:callable_iterator.__init__(callable, sentinel) "{{{1
  let self._callable = a:callable
  let self._sentinel = a:sentinel
endfunction

" TODO: self.callable can be method of other object,
" but it will forget the original self after put into
" callable_iterator.
" The callable module can detect this and create a method
" wrapper.
function! s:callable_iterator.__next__() "{{{1
  let Next = object#builtins#func#CallFuncref(self._callable)
  " TODO: __eq__()
  if Next ==# self._sentinel
    call object#StopIteration()
  endif
  return Next
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
