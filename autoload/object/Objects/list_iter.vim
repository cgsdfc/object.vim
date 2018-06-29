let s:listiter = object#Lib#builtins#IteratorType_New('list_iterator')
let s:listiter.__final__ = 1

function! s:listiter.__init__(list) "{{{1
  let self._index = 0
  let self._list = a:list
endfunction

function! s:listiter.__next__() "{{{1
  try
    let N = self._list[self._index]
  catch 'E684:'
    " list index out of range.
    call object#StopIteration()
  endtry
  let self._index += 1
  return N
endfunction

let s:listreviter = object#Lib#builtins#IteratorType_New('list_reverseiterator')
let s:listreviter.__final__ = 1

" Note: To tell the truth, I don't quite understand why Python has a
" separated list_reverseiterator for list while other sequences all use
" plain reversed object.
function! s:listreviter.__init__(list) "{{{1
  let self._seqn = a:list
  let self._index = len(a:list) - 1
endfunction

function! s:listreviter.__next__() "{{{1
  if self._index == -1
    call object#StopIteration()
  endif
  let N = self._seqn[self._index]
  let self._index -= 1
  return N
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
