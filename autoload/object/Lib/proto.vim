" This file is filled all the checkers, IsXXX() stuffs.

function! object#Lib#proto#HasMethod(X, name) abort "{{{1
  " Return whether object X has a protocol.
  return object#Lib#value#IsObj(a:X) && has_key(a:X, a:name)
        \ && object#Lib#value#IsFuncref(a:X[a:name])
endfunction

function! object#Lib#proto#IsIterable(X) abort "{{{1
  " Object with __iter__().
  return object#Lib#value#IsSequence(a:X) || object#Lib#proto#HasMethod(a:X, '__iter__')
endfunction

" Object with __next__().
function! object#Lib#proto#IsIterator(X) abort "{{{1
  return object#Lib#proto#HasMethod(a:X, '__next__')
endfunction

function! object#Lib#proto#IsSequence(X) abort "{{{1
  " Return whether object X is a Sequence.
  " - Builtin sequences.
  " - Object with __len__() and __getitem__().
  return object#Lib#value#IsSequence(a:X) ||
        \ (object#Lib#proto#HasMethod(a:X, '__len__') &&
        \ object#Lib#proto#HasMethod(a:X, '__getitem__'))
endfunction

function! object#Lib#proto#IsSubscriptable(X) abort "{{{1
  " getitem() is applicable.
  return object#Lib#value#IsContainer(a:X) || object#Lib#value#IsString(a:X) ||
        \ object#Lib#proto#HasMethod(a:X, '__getitem__')
endfunction

function! object#Lib#proto#IsSubscriptAssignable(X) abort "{{{1
  " setitem() is applicable.
  return object#Lib#value#IsContainer(a:X) ||
        \ object#Lib#proto#HasMethod(a:X, '__setitem__')
endfunction

function! object#Lib#proto#IsSubscriptDeletable(X) abort "{{{1
  " delitem() is applicable.
  return object#Lib#value#IsContainer(a:X) ||
        \ object#Lib#proto#HasMethod(a:X, '__delitem__')
endfunction

function! object#Lib#proto#IsHashable(X) abort "{{{1
  " - Builtin immutable types.
  " - __hash__().
  return !object#Lib#value#IsContainer(a:X) ||
        \ object#Lib#proto#HasMethod(a:X, '__hash__')
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
