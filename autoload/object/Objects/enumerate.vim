let s:enumobj = object#Lib#builtins#IteratorType_New('enumerate')

" Note: enumerate is subclassable, that's why moving
" logic into __init__.
function! s:enumobj.__init__(iterable, ...) "{{{1
  call object#Lib#args#TakeAtMostOptional('enumerate', 1, a:0)
  let self._iterable = object#iter(a:iterable)
  let self._index = a:0 ? object#Lib#value#CheckNumber2(a:1) : 0
endfunction

function! s:enumobj.__next__() "{{{1
  let next = [self._index, object#next(self._iterable)]
  let self._index += 1
  return next
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
