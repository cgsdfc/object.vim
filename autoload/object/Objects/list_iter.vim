" FINAL CLASS: list_iterator {{{1
call object#class#builtin_class('list_iterator', s:object, s:)
let s:list_iterator.__final__ = 1

function! s:list_iterator.__init__(list)
  let self.idx = 0
  let self.list = a:list
endfunction

let s:list_iterator.__iter__ = object#slots#iter_self()
let s:list_iterator.__setattr__ = object#slots#readonly_attribute()

function! s:list_iterator.__next__()
  try
    let Item = self.list[self.idx]
  catch 'E684:'
    " list index out of range.
    call object#StopIteration()
  endtry
  let self.idx += 1
  return Item
endfunction

" }}}1

" FINAL CLASS: list_reverseiterator {{{1
call object#class#builtin_class('list_reverseiterator', s:object, s:)
let s:list_reverseiterator.__final__ = 1

" Note: To tell the truth, I don't quite understand why Python has a
" separated list_reverseiterator for list while other sequences all use
" plain reversed object.
function! s:list_reverseiterator.__init__(list)
  let self._seqn = a:list
  let self._index = len(a:list) - 1
endfunction

function! s:list_reverseiterator.__next__()
  if self._index == -1
    call object#StopIteration()
  endif
  let N = self._seqn[self._index]
  let self._index -= 1
  return N
endfunction

let s:list_reverseiterator.__iter__ = object#slots#iter_self()
let s:list_reverseiterator.__setattr__ = object#slots#readonly_attribute()

" }}}1

" FUNCTION: iter() {{{1
function! object#list#iter#iter(list)
  return object#new(s:list_iterator, a:list)
endfunction
" }}}2

" FUNCTION: reversed() {{{1
function! object#list#iter#reversed(list)
  return object#new(s:list_reverseiterator, a:list)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
