let s:reversed = object#Lib#builtins#IteratorType_New('reversed')

function! s:reversed.__new__(seqn) "{{{1
  let seqn = s:CheckReversible(a:seqn)
  if object#Lib#value#IsList(seqn)
    return object#Lib#builtins#Object_New('list_reverseiterator', seqn)
  endif
  if object#Lib#proto#HasProtocol(seqn, '__reversed__')
    return object#builtin#func#CallFuncref(seqn.__reversed__)
  endif
  let obj = object#Lib#class#Object_New(s:reversed)
  let obj._seqn = a:seqn
  let obj._index = object#len(a:seqn) - 1
  return obj
endfunction

function! s:reversed.__next__() "{{{1
  if self._index == -1
    call object#StopIteration()
  endif
  let N = object#getitem(self._seqn, self._index)
  let self._index -= 1
  return N
endfunction

function! s:CheckReversible(X) "{{{1
  if s:IsReversible(a:X)
    return a:X
  endif
  call object#TypeError("'%s' object is not reversible",
        \ object#Lib#value#TypeName(a:X))
endfunction

" - object with __reversed__()
" - Sequence object
" - Builtin sequence.
function! s:IsReversible(X) "{{{1
  return object#Lib#proto#HasProtocol(a:X, '__reversed__') ||
        \ object#Lib#proto#IsSequence(a:X)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
