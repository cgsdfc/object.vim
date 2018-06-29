function! object#Lib#proto#HasProtocol(X, name) abort "{{{1
  " Return whether object X has a protocol.
  return object#builtin#IsObj(a:X) && has_key(a:X, a:name)
        \ && object#builtin#IsFuncref(a:X[a:name])
endfunction

function! object#Lib#proto#IsIterable(X) abort "{{{1
  " Object with __iter__().
  return object#builtin#IsSequence(a:X) || object#Lib#proto#HasProtocol(a:X, '__iter__')
endfunction

" Object with __next__().
function! object#Lib#proto#IsIterator(X) abort "{{{1
  return object#Lib#proto#HasProtocol(a:X, '__next__')
endfunction

function! object#Lib#proto#IsSequence(X) abort "{{{1
  " Return whether object X is a Sequence.
  " - Builtin sequences.
  " - Object with __len__() and __getitem__().
  return object#builtin#IsSequence(a:X) ||
        \ (object#Lib#proto#HasProtocol(a:X, '__len__') &&
        \ object#Lib#proto#HasProtocol(a:X, '__getitem__'))
endfunction

function! object#Lib#proto#IsSubscriptable(X) abort "{{{1
  " getitem() is applicable.
  return object#builtin#IsContainer(a:X) || object#builtin#IsString(a:X) ||
        \ object#Lib#proto#HasProtocol(a:X, '__getitem__')
endfunction

function! object#Lib#proto#IsSubscriptAssignable(X) abort "{{{1
  " setitem() is applicable.
  return object#builtin#IsContainer(a:X) ||
        \ object#Lib#proto#HasProtocol(a:X, '__setitem__')
endfunction

function! object#Lib#proto#IsSubscriptDeletable(X) abort "{{{1
  " delitem() is applicable.
  return object#builtin#IsContainer(a:X) ||
        \ object#Lib#proto#HasProtocol(a:X, '__delitem__')
endfunction

function! object#Lib#proto#IsHashable(X) abort "{{{1
  " - Builtin immutable types.
  " - __hash__().
  return !object#builtin#IsContainer(a:X) ||
        \ object#Lib#proto#HasProtocol(a:X, '__hash__')
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
