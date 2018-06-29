let s:str_iterator = object#Lib#builtins#IteratorType_New('str_iterator')
let s:str_iterator.__final__ = 1

function! s:str_iterator.__init__(str) "{{{1
  let self._index = 0
  let self._string = a:str
endfunction

" When the index to a string goes out of range, Vim
" returns an empty string, which is an indicator of StopIteration.
function! s:str_iterator.__next__() "{{{1
  let N = self._string[self._index]
  if N is ''
    call object#StopIteration()
  endif
  let self._index += 1
  return N
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
