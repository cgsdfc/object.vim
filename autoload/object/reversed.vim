" CLASS: reversed {{{1
call object#class#builtin_class('reversed', s:object, s:)

" METHOD: __init__() {{1
function! s:reversed.__init__(seqn)
  let self._seqn = a:seqn
  let self._index = object#len(a:seqn) - 1
endfunction

" METHOD: __next__() {{{1
function! s:reversed.__next__()
  if self._index == -1
    call object#StopIteration()
  endif
  let N = object#getitem(self._seqn, self._index)
  let self._index -= 1
  return N
endfunction

let s:reversed.__iter__ = object#slots#iter_self()
let s:reversed.__setattr__ = object#slots#readonly_attribute2()

" FUNCTION: reversed() {{{1
function! object#iter#reversed(obj)
  let obj = object#reversed#CheckReversible(a:obj)
  if object#builtin#IsList(obj)
    " list_reverseiterator
    return object#list#reversed(obj)
  endif
  if has_key(obj, '__reversed__')
    return object#builtin#Call(obj.__reversed__)
  endif
  return object#new(s:reversed, obj)
endfunction

" FUNCTION: CheckReversible() {{{1
function! object#reversed#CheckReversible(X)
  if object#reversed#IsReversible(a:X)
    return a:X
  endif
  call object#TypeError("'%s' object is not reversible",
        \ object#builtin#TypeName(a:X))
endfunction

" FUNCTION: IsReversible() {{{1
" - object with __reversed__()
" - Sequence object
" - Builtin sequence.
function! object#reversed#IsReversible(X)
  return object#protocol#HasProtocol(a:X, '__reversed__') ||
        \ object#protocol#IsSequence(a:X)
endfunction
" }}}1

" vim: set sw=2 sts=2 et fdm=marker:
