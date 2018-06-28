" CLASS: enumerate {{{1
let s:enumerate = object#Lib#builtins#Type_New('enumerate')

let s:enumerate.__iter__ = function('object#Lib#slots#iter_self')
let s:enumerate.__setattr__ = function('object#Lib#slots#readonly_attribute')

" Note: enumerate is subclassable, that's why moving
" logic into __init__.
function! s:enumerate.__init__(iterable, ...)
  call object#Lib#args#TakeAtMostOptional('enumerate', 1, a:0)
  let self._iterable = object#iter(a:iterable)
  let self._index = a:0 ? object#Lib#value#CheckNumber2(a:1) : 0
endfunction

function! s:enumerate.__next__()
  let next = [self._index, object#next(self._iterable)]
  let self._index += 1
  return next
endfunction
" }}}1

" vim: set sw=2 sts=2 et fdm=marker:
